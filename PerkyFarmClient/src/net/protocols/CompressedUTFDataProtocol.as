package net.protocols 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import net.serialize.ISerializer;
	
	/**
	 * Класс протокол передающих строчные данные (JSON, XML, и пр.) в 
	 * сжатом битовом формате
	 * ...
	 * @author Alex Sarapulov
	 */
	[Event(name="connect", type="flash.events.Event")]
	[Event(name="close", type="flash.events.Event")]
	public class CompressedUTFDataProtocol extends AbstactProtocol 
	{
		/**
		 * Мультиплайер времени переподключения к удаленному хосту
		 * 
		 */
		public static var RECONNECT_TIMEOUT_MULTIPLIER:Number = 2;
		
		/**
		 * Начальное значение таймаута переподключения
		 * 
		 */
		public static var START_RECONNECT_TIMEOUT:Number = 100;
		
		/**
		 * Триггер запуска переподключения, true - запускать перезагрузку при сбое подключения
		 * @private
		 */
		protected var _forceReconnection:Boolean;
		
		/**
		 * Значение задержки при переподключении
		 * @private
		 */
		protected var _reconnectTimeout:int;
		
		/**
		 * id таймаута переподключения (нужен для удаления)
		 * @private
		 */
		protected var _timer:int = -1;
		
		/**
		 * Хост подключения
		 * @private
		 */
		protected var _host:String;
		
		/**
		 * Порт подключения
		 * @private
		 */
		protected var _port:uint;
		
		protected var _socket:Socket;
		/**
		 * Сокетное соединение
		 * 
		 */
		public function get socket():Socket { return _socket; }
		/**
		 * Установщик сокетного соединения
		 * @private
		 */
		public function set socket(value:Socket):void {
			clearSocket(); // если сокет существует, то очищаем
			_socket = value;
			if (_socket.connected)
				connectHandler(); // если сокет уже был подключен то запускаем инициализацию
			addListeners();
		}
		
		/**
		 * Триггер доступности удаленного объекта
		 * 
		 */
		override public function get isOpen():Boolean {
			return _socket && _socket.connected;
		}
		
		/**
		 * Триггер процесса подключения
		 * @private
		 */
		protected var _connecting:Boolean;
		
		/**
		 * Триггер передачи пакета, true - буфер занят
		 * @private
		 */
		protected var _busy:Boolean;
		
		/**
		 * Очередь отправленных цельных пакетов
		 * @private
		 */
		protected var _queue:Array;
		
		/**
		 * Конструктор класса протокола
		 * 
		 * @param	serializer Сериализатор данных (переводит данные в строковый формат и обратно в объект при получении ответа)
		 * @param	receiveHandler Обработчик получения запроса или сообщения
		 * @param	socket Сокет подключения
		 * @param	forceReconnection Форсировать переподключение при потере соединения с удаленным хостом
		 * 
		 */
		public function CompressedUTFDataProtocol(serializer:ISerializer, receiveHandler:Function, socket:Socket = null, forceReconnection:Boolean = false) 
		{
			_reconnectTimeout = START_RECONNECT_TIMEOUT;
			_forceReconnection = forceReconnection;
			_queue = [];
			if (socket)
				this.socket = socket;
			super(serializer, receiveHandler);
		}
		
		/**
		 * Запуск соединения
		 * 
		 * @param	host Хост соединения
		 * @param	port Порт соединения
		 * 
		 */
		override public function connect(host:String = null, port:* = null):void
		{
			if (_timer != -1) {
				clearTimeout(_timer);
				_timer = -1;
			}
			if (host) _host = host;
			if (port is int) _port = port;
			if (!_host || !_port) throw("Bad socket connection end point");
			if (!_socket)
				socket = new Socket();
			if (!_socket.connected) {
				_socket.connect(_host, _port);
				_connecting = true;
			}
		}
		
		/**
		 * Передача объекта (данных) удаленному хосту
		 * 
		 * @param	object
		 * 
		 */
		override public function send(object:*):void
		{
			var data:String = String(_serializer.encode(object));
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeUTFBytes(data);
			byteArray.compress();
			if (!isOpen && !_forceReconnection && !_connecting)
				throw("Protocol closed");
			if (!_busy && _queue.length == 0 && isOpen)
				sendNext(byteArray); // если очередь пуста и передача доступна, форсируем
			else
				_queue.push(byteArray); // транспорт занят, положим в очередь
		}
		
		/**
		 * Передача следующего по очереди объекта данных
		 * 
		 * @param	byteArray Сжатые данные, которые передаются на уровень транспортного протокола
		 * @private
		 */
		protected function sendNext(byteArray:ByteArray = null):void
		{
			if (_busy || !isOpen) return;
			_busy = true;
			if (!byteArray) {
				if (_queue.length == 0) {
					_busy = false;
					return;
				}
				var data:Object = _queue.shift();
				byteArray = data as ByteArray;
			}
			_socket.writeInt(byteArray.length);
			_socket.writeBytes(byteArray);
			_socket.flush();
			_busy = false;
			sendNext();
		}
		
		// ------ socket handlers
		
		/**
		 * Обработчик подключения сокета
		 * 
		 * @param	event Событие, оповещающее о создании подключения
		 * @private
		 */
		protected function connectHandler(event:Event = null):void
		{
			_reconnectTimeout = START_RECONNECT_TIMEOUT;
			_connecting = false;
			dispatchEvent(new Event(Event.CONNECT));
			if (_queue.length > 0)
				sendNext();
		}
		
		/**
		 * Объем скачиваемого в данный момент пакета
		 * @private
		 */
		protected var _bytesTotal:Number = 0;
		
		/**
		 * Скачиваемы в данный момент пакет данных
		 * @private
		 */
		protected var _currentPackage:ByteArray;
		
		/**
		 * Обработчик получения сокетных данных
		 * 
		 * @param	event Событие, оповещающее о наличии новых данных в входном буфере
		 * @private
		 */
		protected function dataReceiveHandler(event:ProgressEvent):void
		{
			if (_bytesTotal == 0) {
				// инициализируем как новый пакет
				_currentPackage = new ByteArray();
				_bytesTotal = _socket.readInt();
			}
			if (!_socket.bytesAvailable) return;
			var numBytes:uint = Math.min(_bytesTotal - _currentPackage.length, _socket.bytesAvailable);
			_socket.readBytes(_currentPackage, _currentPackage.length, numBytes);
			if (_currentPackage.length == _bytesTotal) {
				// завершим работу с пакетом
				var byteArray:ByteArray = _currentPackage;
				_currentPackage = null;
				_bytesTotal = 0;
				var object:*;
				byteArray.uncompress();
				var data:String = byteArray.readUTFBytes(byteArray.length);
				object = _serializer.decode(data);
				// передаем готовый объект получателю
				_receiveHandler(object);
			}
		}
		
		/**
		 * Обработчик закрытия сокета
		 * 
		 * @param	event Событие, оповещающее о потере соединения с удаленных хостом
		 * @private
		 */
		protected function closeHandler(event:Event):void
		{
			if (_forceReconnection)
				reconnect();
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		/**
		 * Процессор переподключения
		 * @private
		 */
		protected function reconnect():void
		{
			if (isOpen) return
			_reconnectTimeout *= RECONNECT_TIMEOUT_MULTIPLIER;
			_timer = setTimeout(connect, _reconnectTimeout);
		}
		
		/**
		 * Обработчик ошибки ввода-вывода
		 * 
		 * @param	event Событие, оповещающее о возникновении ошибки ввода-вывода соединения
		 * @private
		 */
		protected function ioErrorHandler(event:IOErrorEvent):void 
		{
			if (_forceReconnection) reconnect();
			else throw(event);
		}
		
		/**
		 * Обработчик ошибки доступа
		 * 
		 * @param	event Событие, оповещающее о возникновении ошибки попытки нарушения прав пользователя в соединении
		 * @private
		 */
		protected function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			if (_forceReconnection) reconnect();
			else throw(event);
		}
		
		// ------ clearing
		
		/**
		 * Деструктор протокола
		 * 
		 */
		override public function dispose():void
		{
			if (_timer != -1) clearTimeout(_timer);
			clearSocket();
			_busy = false;
			_connecting = false;
			_queue = null;
			_forceReconnection = false;
			_host = null;
			_port = 0;
			
			_currentPackage = null;
			_bytesTotal = 0;
			
			super.dispose();
		}
		
		/**
		 * Очистка сокетного соединения
		 * @private
		 */
		protected function clearSocket():void
		{
			if (!_socket) return;
			removeListeners();
			if (_socket.connected)
				_socket.close();
			_socket = null;
		}
		
		// ------ socket listeners
		
		/**
		 * Добавление обработчиков сокета
		 * @private
		 */
		protected function addListeners():void
		{
			_socket.addEventListener(Event.CONNECT, connectHandler);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, dataReceiveHandler);
			_socket.addEventListener(Event.CLOSE, closeHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}
		
		/**
		 * Удаление обработчиков сокета
		 * @private
		 */
		protected function removeListeners():void
		{
			_socket.removeEventListener(Event.CONNECT, connectHandler);
			_socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataReceiveHandler);
			_socket.removeEventListener(Event.CLOSE, closeHandler);
			_socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}
	}

}