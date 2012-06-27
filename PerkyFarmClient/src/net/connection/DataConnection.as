package net.connection 
{
	import flash.events.Event;
	import flash.net.Socket;
	import flash.utils.getTimer;
	import net.protocols.IProtocol;
	
	/**
	 * Класс контролирующий соединение с удаленным хостом и обмен данным с ним 
	 * ...
	 * @author Alex Sarapulov
	 */
	public class DataConnection
	{
		protected var _id:String;
		/**
		 * Идентификатор соединения
		 * 
		 */
		public function get id():String { return _id; }
		
		/**
		 * Ссылка на обработчик вызовов
		 * @private
		 */
		protected var _callHandler:Function;
		
		/**
		 * Ссылка на клиента
		 * @private
		 */
		protected var _client:*;
		
		protected var _protocol:IProtocol;
		/**
		 * Транспортный протокол
		 * 
		 */
		public function get protocol():IProtocol { return _protocol; }
		
		/**
		 * Пакеты, находящиеся в обработке
		 * @private
		 */
		protected var _packages:Object = {};
		
		/**
		 * Конструктор класса соединения
		 * 
		 */
		public function DataConnection(id:String, callHandler:Function, client:*, ProtocolClass:Class, serializer:*, socket:Socket, forceReconnection:Boolean = false) 
		{
			_id = id;
			_callHandler = callHandler;
			_client = client;
			_protocol = new ProtocolClass(serializer, dataReceiveHandler, socket, forceReconnection) as IProtocol;
		}
		
		/**
		 * Создание соединения (вызывается только для объекта, который инициирует подключение)
		 * 
		 * @param	host Удаленный хост соединения
		 * @param	port Удаленный порт соединения
		 * 
		 */
		public function connect(host:String, port:int):void
		{
			_protocol.connect(host, port);
		}
		
		/**
		 * Формирование пакета и передача вызова удаленному объекту
		 * 
		 * @param	method Метод удаленного вызова
		 * @param	data Передаваемые данные
		 * @param	callback Обработчик результата вызова
		 * 
		 */
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
		
		/**
		 * Формирование ответного пакета
		 * 
		 * @param	timestamp Идентификатор (и время передачи) сообщения, выставляется отправителем
		 * @param	method Вызываемый метод
		 * @param	data Данные результата вызова
		 * 
		 */
		public function sendRequest(timestamp:String, method:String, data:Object):void
		{
			var messageData:Object = {
				timestamp: timestamp,
				method: method,
				data: data
			}
			_protocol.send(messageData);
		}
		
		/**
		 * Обработчик получения данных с сервера
		 * 
		 * @param	result Результат полученный с удаленного хоста
		 */
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
				/*var error:Object = data['error'];
				if (error != null)
					throw("SERVER_ERROR: method=" + method + ", code=" + error.code + ", message=" + error.message);*/
			} else { // если вызов был произведен с удаленного объекта
				method = result['method'];
				_callHandler(_client, method, data, function(data:*):void {
					sendRequest(timestamp, method, data);
				});
			}
			if (_packages.hasOwnProperty(messageID))
				delete _packages[timestamp];
		}
		
		/**
		 * Завершение работы соединения
		 * 
		 */
		public function close():void
		{
			_protocol.dispose();
			_protocol = null;
			_packages = null;
			_callHandler = null;
			_client = null;
		}
		
		/**
		 * Получение синхронного времени
		 * 
		 * @return Значение синхронного времени
		 * 
		 */
		public function getSyncronicTime():int
		{
			// TODO(Alex Sarapulov): make this
			return getTimer();
		}
		
	}

}