package controllers
{
	import display.ResourceStorage;
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
		
		protected var _resourceStorage:ResourceStorage;
		
		// объект контроля соединения
		protected var _client:Client;
		public function get client():Client { return _client; }
		
		// -- конструктор
		public function ClientConnectionController()
		{
			_client = new Client(this, null, true);
			super();
			_resourceStorage = new ResourceStorage();
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
		
		// ------ user api
		
		// асинхронное получение ресурса
		override public function getResource(url:String, callback:Function):void
		{
			_resourceStorage.getResource(url, callback);
		}
		
		// получение данных о пользователе
		override public function getUserData(userID:String, callback:Function):void
		{
			_client.connection.send("getUserData", userID, callback);
		}
		
		// получение данных о типе объекта на карте
		override public function getItemTypeData(itemType:String, callback:Function):void
		{
			
		}
		
		// установка нового объекта в заданную точку карты
		override public function placeItem(client:Client, itemType:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			var res:Boolean = super.placeItem(_client, itemType, xpos, ypos, callback);
			if (res) client.connection.send("placeItem", { item_type: itemType, x: xpos, y: ypos }, callback);
			return res;
		}
		
		// перемещения объекта на карте
		override public function moveItem(client:Client, itemID:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			var res:Boolean = super.moveItem(_client, itemID, xpos, ypos, callback);
			if (res) client.connection.send("moveItem", { id: itemID, x: xpos, y: ypos }, callback);
			return res;
		}
		
		// сбор объекта
		override public function collectItem(client:Client, itemID:String, callback:Function):Boolean
		{
			var res:Boolean = super.collectItem(_client, itemID, callback);
			if (res) client.connection.send("collectItem", itemID, callback);
			return res;
		}
		
		// обновление уровня у всех объектов на карте
		override public function upgradeItems(client:Client, itemIDs:Array, callback:Function):Array
		{
			var res:Array = super.upgradeItems(_client, itemIDs, callback) as Array;
			if (res && res.length > 0)
				client.connection.send("upgradeAllItems", res, callback);
			return res;
		}
		
		// -- request handlers
		
		// получение запроса от сервера
		override public function call(client:Client, method:String, data:*, callback:Function):void
		{
			// TODO(Alex Sarapulov): make handler
			trace("get some request");
			callback(data);
		}
		
	}
}