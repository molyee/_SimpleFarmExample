package net.connection 
{
	import flash.events.Event;
	import flash.net.Socket;
	import flash.utils.getTimer;
	import net.protocols.IProtocol;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class DataConnection
	{
		// идентификатор соединения
		protected var _id:String;
		public function get id():String { return _id; }
		
		// ссылка на обработчик вызовов
		protected var _callHandler:Function;
		
		// ссылка на клиента
		protected var _client:*;
		
		// транспортный протокол
		protected var _protocol:IProtocol;
		public function get protocol():IProtocol { return _protocol; }
		
		// пакеты, находящиеся в обработке
		protected var _packages:Object = {};
		
		// -- конструктор
		public function DataConnection(id:String, callHandler:Function, client:*, ProtocolClass:Class, serializer:*, socket:Socket, forceReconnection:Boolean = false) 
		{
			_id = id;
			_callHandler = callHandler;
			_client = client;
			_protocol = new ProtocolClass(serializer, dataReceiveHandler, socket, forceReconnection) as IProtocol;
		}
		
		// создание соединения (вызывается только для объекта, который инициирует подключение)
		public function connect(host:String, port:int):void
		{
			_protocol.connect(host, port);
		}
		
		// формирование пакета и передача вызова удаленному объекту
		public function send(method:String, data:Object = null, callback:Function = null):void
		{
			var timestamp:String = getSyncronicTime().toString();
			var messageID:String = timestamp + "_" + _id;
			_packages[messageID] = {
				timestamp: timestamp,
				method: method,
				callback: callback,
				data: data
			}
			sendRequest(timestamp, method, data);
		}
		
		// формирование ответного пакета
		public function sendRequest(timestamp:String, method:String, data:Object):void
		{
			var messageData:Object = {
				timestamp: timestamp,
				method: method,
				data: data
			}
			_protocol.send(messageData);
		}
		
		// обработчик получения данных с сервера
		protected function dataReceiveHandler(result:Object):void
		{
			var data:Object = result['data'];
			var timestamp:String = result['timestamp'];
			var method:String;
			var callback:Function;
			
			var messageID:String = timestamp + "_" + id;
			var messageData:Object = _packages[messageID];
			var isLocalRequest:Boolean = messageData != null;
			if (isLocalRequest) { // если вызов был инициирован локальным кодом
				method = messageData['method'];
				callback = messageData['callback'];
				if (callback != null)
					callback(data);
				var error:Object = data['error'];
				if (error != null)
					throw("SERVER_ERROR: method=" + method + ", code=" + error.code + ", message=" + error.message);
			} else { // если вызов был произведен с удаленного объекта
				method = result['method'];
				_callHandler(_client, method, data, function(data:*):void {
					sendRequest(timestamp, method, data);
				});
			}
			if (_packages.hasOwnProperty(messageID))
				delete _packages[timestamp];
		}
		
		// завершение работы соединения
		public function close():void
		{
			_protocol.dispose();
			_protocol = null;
			_packages = null;
			_callHandler = null;
			_client = null;
		}
		
		// получение синхронного времени
		public function getSyncronicTime():int
		{
			// TODO(Alex Sarapulov): make this
			return getTimer();
		}
		
	}

}