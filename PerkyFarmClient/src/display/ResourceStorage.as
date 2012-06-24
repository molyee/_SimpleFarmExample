package display 
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import net.protocols.BitDataProtocol;
	import net.serialize.UTFBitSerializer;
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ResourceStorage 
	{
		// хранилище загруженных ресурсов с доступом по url адресу
		private var _storage:Object;
		
		// слушатели, ожидающие загрузки ресурса
		private var _callbacks:Object;
		
		// загрузчик статики
		private var _loader:BitDataProtocol;
		
		private var _queue:Array; // очередь запросов на получение статики
		private var _busy:Boolean; // триггер ожидания
		private var _currentUrl:String; // загружаемый ресурс
		
		// триггер подключения
		private var _connected:Boolean;
		
		// сериализатор данных
		private var _serializer:UTFBitSerializer;
		
		// -- конструктор
		public function ResourceStorage() 
		{
			_storage = { };
			_callbacks = { };
			_queue = [];
			
			_serializer = new UTFBitSerializer();
			
			BitmapDataLoader.STORAGE = this;
			
			_busy = true;
			
			_loader = new BitDataProtocol(resourceReceiveHandler, null, true);
			_loader.addEventListener(Event.CLOSE, closeProtocolHandler);
			_loader.addEventListener(Event.CONNECT, connectProtocolHandler);
			connect();
		}
		
		// запуск создания соединения
		private function connect():void
		{
			_loader.connect(Settings.RESOURCE_HOST, Settings.RESOURCE_PORT);
		}
		
		// обработчик события подключения к удаленному хосту
		private function connectProtocolHandler(event:Event):void 
		{
			_connected = true;
			_busy = false;
			if (_queue.length > 0)
				getNext();
		}
		
		// обработчик закрытия протокола
		private function closeProtocolHandler(event:Event):void 
		{
			_connected = false;
		}
		
		// получение ресурса (из кеша или с удаленного адреса)
		public function getResource(url:String, callback:Function):void
		{
			var content:* = _storage[url];
			if (content)
				callback(content);
			else
				loadResource(url, callback);
		}
		
		// загрузка контента с удаленного адреса
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
		
		// получение следующего в очереди ресурса
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
		
		// отправка url(uuid) ресурса
		private function sendUrl(url:String):void
		{
			var urlByteArray:ByteArray = _serializer.encode(url) as ByteArray;
			_loader.send(urlByteArray);
		}
		
		// обработчик получения данных ресурса
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
		
		// парсер XML данных
		protected function parseXML(data:ByteArray):XML
		{
			var str:String = data.readUTFBytes(data.length);
			var xml:XML = new XML(str);
			return xml;
		}
		
		// парсер изображений
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