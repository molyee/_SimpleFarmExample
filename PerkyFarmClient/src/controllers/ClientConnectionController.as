package controllers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import models.User;
	
	import net.connection.Client;
	
	[Event(name="connect", type="flash.events.Event")]
	[Event(name="init", type="flash.events.Event")]
	[Event(name="close", type="flash.events.Event")]
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ClientConnectionController extends ConnectionController
	{
		// триггер соединения с удаленным объектом
		public function get connected():Boolean {
			var result:Boolean = false;
			try {
				result = _client.connection.protocol.isOpen;
			} catch (e:Error) { }
			return result;
		}
		
		// объект контроля соединения
		protected var _client:Client;
		public function get client():Client { return _client; }
		
		// -- конструктор
		public function ClientConnectionController()
		{
			_client = new Client(this, null, true);
			super();
		}
		
		// создание соединения с сервером
		public function connect(host:String, port:int):void
		{
			_client.connection.protocol.addEventListener(Event.CONNECT, connectHandler);
			_client.connection.protocol.addEventListener(Event.CLOSE, closeHandler);
			_client.connection.connect(host, port);
		}
		
		// обработчик события получения соединения с удаленным объектом
		protected function connectHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			(event.currentTarget as IEventDispatcher).removeEventListener(Event.CONNECT, connectHandler);
			dispatchEvent(new Event(Event.CONNECT));
		}
		
		protected function closeHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			(event.currentTarget as IEventDispatcher).removeEventListener(Event.CONNECT, connectHandler);
			(event.currentTarget as IEventDispatcher).removeEventListener(Event.CLOSE, closeHandler);
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		// -- request senders
		
		protected var _loginHandler:Function;
		protected var _logging:Boolean = false; // триггер ожидания авторизации
		// авторизация пользователя
		public function login(login:String, password:String, loginHandler:Function):void
		{
			if (_logging || !connected) return;
			_logging = true;
			_loginHandler = loginHandler;
			if (_inited)
				_inited = false;
			var data:Object = { login: login, password: password };
			CONFIG::debug {
				data['user_data'] = {
					id: "1",
					logged: true,
					items: { },
					inventory: { }
				}
			}
			trace("login with login=" + login + ", password=" + password);
			_client.connection.send("login", { login:login, password:password }, loginResultHandler);
		}
		
		// обработчик получения результата авторизации
		protected function loginResultHandler(result:Object):void
		{
			if (!result || result['error'] != null) {
				throw(result['error']);
			}
			trace("client logged");
			_inited = true;
			_logging = false;
			_loginHandler(result);
			_loginHandler = null;
			_client.currentUser.update(result['user_data']);
			dispatchEvent(new Event(Event.INIT));
		}
		
		// установка нового объекта в заданную точку карты
		public function placeItem(itemType:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			return super._placeItem(_client, itemType, xpos, ypos, callback);
		}
		
		// перемещения объекта на карте
		public function moveItem(itemID:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			return super._moveItem(_client, itemID, xpos, ypos, callback);
		}
		
		// сбор объекта
		public function collectItem(itemID:String, callback:Function):Boolean
		{
			return super._collectItem(_client, itemID, callback);
		}
		
		// обновление уровня у всех объектов на карте
		public function upgradeAllItems(callback:Function):Boolean
		{
			return super._upgradeAllItems(_client, callback);
		}
		
		// -- request handlers
		
		// получение запроса от сервера
		override public function call(client:Client, method:String, data:Object, callback:Function):void
		{
			// TODO(Alex Sarapulov): make handler
			trace("get some request");
			callback(data);
		}
		
	}
}