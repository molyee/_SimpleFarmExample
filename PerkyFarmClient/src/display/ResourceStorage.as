package display 
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import net.protocols.BitDataProtocol;
	import net.serialize.UTFBitSerializer;
	/**
	 * Класс реализует кеширующее хранилище статических или редко изменяющихся 
	 * ресурсов. Выдача данных производится по первому запросу на получение 
	 * ресурса, при этом загружается объект всего один раз, если до завершения загрузки
	 * объекта другой процесс запросил загружаемый ресурс, то его обработчик получения
	 * данных добавляется в список слушателей загрузки ресурса. По завершению загрузки
	 * вызываются все обработчики ожидающие загруженный ресурс, сам же ресурс сохраняется
	 * в хранилище (кеше), и позже может быть получен уже без загрузки, а напрямую из хранилища
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ResourceStorage 
	{
		/**
		 * Хранилище загруженных ресурсов с доступом по url адресу
		 * @private
		 */
		private var _storage:Object;
		
		/**
		 * Слушатели, ожидающие загрузки ресурса
		 * @private
		 */
		private var _callbacks:Object;
		
		/**
		 * Загрузчик статики
		 * @private
		 */
		private var _loader:BitDataProtocol;
		
		/**
		 * Очередь запросов на получение статики
		 * @private
		 */
		private var _queue:Array;
		
		/**
		 * Триггер ожидания загрузки, значение true говорит о том, что
		 * запрос на получение данных с сервера был отправлен, но данные еще не пришли
		 * @private
		 */
		private var _busy:Boolean;
		
		/**
		 * Загружаемый в данный момент ресурс
		 * @private
		 */
		private var _currentUrl:String;
		
		/**
		 * Триггер подключения, говорит о доступности удаленного объекта
		 * @private
		 */
		private var _connected:Boolean;
		
		/**
		 * Объект обеспечивающих преобразование данных для передачи в протокол
		 * и получения из канала данных
		 * @private
		 */
		private var _serializer:UTFBitSerializer;
		
		/**
		 * Конструктор хранилища данных
		 * 
		 */
		public function ResourceStorage() 
		{
			// создаем списки
			_storage = { };
			_callbacks = { };
			_queue = [];
			
			// создаем объект сериализатора
			_serializer = new UTFBitSerializer();
			
			//инициализируем загрузчик растровых данных
			BitmapDataLoader.STORAGE = this;
			
			// перед запуском попытки соединения с сервером выставляем флаг занятости
			_busy = true;
			
			// соединяемся с сервером статики по битовому протоколу
			_loader = new BitDataProtocol(resourceReceiveHandler, null, true);
			_loader.addEventListener(Event.CLOSE, closeProtocolHandler);
			_loader.addEventListener(Event.CONNECT, connectProtocolHandler);
			connect();
		}
		
		/**
		 * Запуск создания соединения с сервером статики
		 * 
		 */
		private function connect():void
		{
			_loader.connect(Settings.RESOURCE_HOST, Settings.RESOURCE_PORT);
		}
		
		/**
		 * Обработчик события подключения к удаленному хосту
		 * 
		 * @param	event Событие подключения к серверу
		 * @private
		 */
		private function connectProtocolHandler(event:Event):void 
		{
			_connected = true;
			_busy = false;
			if (_queue.length > 0)
				getNext();
		}
		
		/**
		 * Обработчик закрытия протокола
		 * 
		 * @param	event Событие закрытие соединения с сервером
		 * @private
		 */
		private function closeProtocolHandler(event:Event):void 
		{
			_connected = false;
		}
		
		/**
		 * Запуск получения ресурса (из кеша или с удаленного адреса)
		 * 
		 * @param	url URL-адрес ресурса или уникальный идентификатор
		 * @param	callback Обработчик получения данных ресурса
		 * 
		 */
		public function getResource(url:String, callback:Function):void
		{
			var content:* = _storage[url];
			if (content) callback(content);
			else loadResource(url, callback);
		}
		
		/**
		 * Загрузка контента с удаленного адреса
		 * 
		 * @param	url URL-адрес ресурса или уникальный идентификатор
		 * @param	callback Обработчик получения данных ресурса
		 * @private
		 */
		private function loadResource(url:String, callback:Function):void
		{
			var callbacks:Array = _callbacks[url] as Array;
			if (callbacks != null) {
				callbacks.push(callback);
				return;
			}
			callbacks = [callback];
			_callbacks[url] = callbacks;
			if (!_busy && _queue.length == 0)
				getNext(url);
			else
				_queue.push(url);
		}
		
		/**
		 * Запуск следующей загрузки, находящейся в очереди или переданной напрямую
		 * 
		 * @param	url URL-адрес ресурса или уникальный идентификатор (если равен null,
		 * то подразумевается, что URL-адрес будет взят из очереди запросов
		 * 
		 */
		private function getNext(url:String = null):void
		{
			if (_busy || (!url && _queue.length == 0))
				return;
			_busy = true;
			if (!_connected) {
				if (url)
					_queue.push(url);
				connect();
				return;
			}
			_currentUrl = url || _queue.shift();
			sendUrl(_currentUrl);
		}
		
		/**
		 * Отправка url(uuid) ресурса на сервер
		 * 
		 * @param	url Идентификатор ресурса
		 * @private
		 */
		private function sendUrl(url:String):void
		{
			var urlByteArray:ByteArray = _serializer.encode(url) as ByteArray;
			_loader.send(urlByteArray);
		}
		
		/**
		 * Обработчик получения данных ресурса
		 * 
		 * @param	protocol Протокол соединения с сервером
		 * @param	data Полученные данные ресурса
		 * @private
		 */
		protected function resourceReceiveHandler(protocol:BitDataProtocol, data:*):void
		{
			var result:*;
			var objectType:String = _currentUrl.substring(_currentUrl.length - 4, _currentUrl.length);
			switch (objectType) {
				case ".xml":
					result = parseXML(data as ByteArray);
					break;
				default:
					result = parseBitmapData(data as ByteArray);
			}
			_storage[_currentUrl] = result;
			var callbacks:Array = _callbacks[_currentUrl];
			for each (var callback:Function in callbacks) {
				callback(result);
			}
			delete _callbacks[_currentUrl];
			_busy = false;
			if (_queue.length > 0)
				getNext();
		}
		
		/**
		 * Парсер XML-данных
		 * 
		 * @param	data Закодированные битовые данные, полученные с сервера
		 * @return Раскодированный XML-объект
		 * 
		 */
		protected function parseXML(data:ByteArray):XML
		{
			var str:String = data.readUTFBytes(data.length);
			var xml:XML = new XML(str);
			return xml;
		}
		
		/**
		 * Парсер изображений
		 * 
		 * @param	data Закодированные битовые данные, полученные с сервера
		 * @return Раскодированные растровые данные
		 * 
		 */
		protected function parseBitmapData(data:ByteArray):BitmapData
		{
			var width:int = data.readInt();
			var height:int = data.readInt();
			var pixels:ByteArray = new ByteArray();
			data.readBytes(pixels);
			
			var rect:Rectangle = new Rectangle(0, 0, width, height);
			var bitmapData:BitmapData = new BitmapData(width, height, true, 0x00000000);
			bitmapData.setPixels(rect, pixels);
			return bitmapData;
		}
	}

}