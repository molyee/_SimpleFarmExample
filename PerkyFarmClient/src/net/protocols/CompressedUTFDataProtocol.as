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
	
	[Event(name="connect", type="flash.events.Event")]
	[Event(name="close", type="flash.events.Event")]
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class CompressedUTFDataProtocol extends AbstactProtocol 
	{
		// скорость увеличения таймаута переподключения при неуспешном коннекте
		public static var RECONNECT_TIMEOUT_MULTIPLIER:Number = 2;
		// начальное значение таймаута переподключения
		public static var START_RECONNECT_TIMEOUT:Number = 100;
		
		protected var _forceReconnection:Boolean; // true - запускать перезагрузку при сбое подключения
		protected var _reconnectTimeout:int; // значение задержки при переподключении
		protected var _timer:int = -1; // id таймаута переподключения
		
		protected var _host:String; // хост подключения
		protected var _port:uint; // порт подключения
		
		// сокетное соединение
		protected var _socket:Socket;
		public function get socket():Socket { return _socket; }
		public function set socket(value:Socket):void {
			clearSocket(); // если сокет существует, то очищаем
			_socket = value;
			if (_socket.connected)
				connectHandler(); // если сокет уже был подключен то запускаем инициализацию
			addListeners();
		}
		
		// триггер доступности удаленного объекта
		override public function get isOpen():Boolean {
			return _socket && _socket.connected;
		}
		
		protected var _connecting:Boolean; // триггер процесса подключения
		protected var _busy:Boolean; // триггер передачи пакета, true - буфер занят
		protected var _queue:Array; // очередь запросов
		
		// -- конструктор
		public function CompressedUTFDataProtocol(serializer:ISerializer, receiveHandler:Function, socket:Socket = null, forceReconnection:Boolean = false) 
		{
			_reconnectTimeout = START_RECONNECT_TIMEOUT;
			_forceReconnection = forceReconnection;
			_queue = [];
			if (socket)
				this.socket = socket;
			super(serializer, receiveHandler);
		}
		
		// запуск соединения
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
		
		// передача объекта
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
		
		// передача следующего по очереди объекта данных
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
		
		// обработчик подключения сокета
		protected function connectHandler(event:Event = null):void
		{
			_reconnectTimeout = START_RECONNECT_TIMEOUT;
			_connecting = false;
			dispatchEvent(new Event(Event.CONNECT));
			if (_queue.length > 0)
				sendNext();
		}
		
		protected var _bytesTotal:Number = 0; // объем ожидаемого пакета
		protected var _currentPackage:ByteArray; // текущий пакет
		// обработчик получения сокетных данных
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
		
		// обработчик закрытия сокета
		protected function closeHandler(event:Event):void
		{
			if (_forceReconnection)
				reconnect();
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		// процессор переподключения
		protected function reconnect():void
		{
			if (isOpen) return
			_reconnectTimeout *= RECONNECT_TIMEOUT_MULTIPLIER;
			_timer = setTimeout(connect, _reconnectTimeout);
		}
		
		// обработчик ошибки ввода-вывода
		protected function ioErrorHandler(event:IOErrorEvent):void 
		{
			if (_forceReconnection) reconnect();
			else throw(event);
		}
		
		// обработчик ошибки доступа
		protected function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			if (_forceReconnection) reconnect();
			else throw(event);
		}
		
		// ------ clearing
		
		// -- деструктор
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
		
		// очистка сокетного соединения
		protected function clearSocket():void
		{
			if (!_socket) return;
			removeListeners();
			if (_socket.connected)
				_socket.close();
			_socket = null;
		}
		
		// ------ socket listeners
		
		// добавление обработчиков сокета
		protected function addListeners():void
		{
			_socket.addEventListener(Event.CONNECT, connectHandler);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, dataReceiveHandler);
			_socket.addEventListener(Event.CLOSE, closeHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}
		
		// удаление обработчиков сокета
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