package controllers 
{
	import database.DBConnection;
	import database.DBObjectTypes;
	import database.ServerResourceStorage;
	
	import errors.UserError;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.Socket;
	import flash.utils.Dictionary;
	
	import logging.Logger;
	
	import models.Item;
	import models.Model;
	import models.User;
	
	import net.connection.Client;

	/**
	 * Класс контроллер сервера
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ServerConnectionController extends ConnectionController
	{
		protected var _clients:Dictionary;
		/**
		 * Список подключенных клиентов с доступом по объекту сокета соединения
		 * 
		 */		
		public function get clients():Dictionary { return _clients; }
		
		/**
		 * Ссылка на контроллер базы данных
		 * 
		 */		
		protected var _db:DBConnection;
		
		protected var _enabled:Boolean;
		/**
		 * Триггер доступности контроллера
		 * 
		 */		
		public function get enabled():Boolean { return _enabled; }
		/**
		 * Установщик флага доступности контроллера
		 * @private
		 */		
		public function set enabled(value:Boolean):void {
			_enabled = value;
			Logger.instance.writeLine("Server controller enabled=" + _enabled);
		}
		
		/**
		 * Ссылка на хранилище статических ресурсов
		 * 
		 */		
		protected var _storage:ServerResourceStorage;
		
		/**
		 * Конструктор контроллера серверного приложения
		 * 
		 * @param databaseConnection Ссылка на контроллер базы данных
		 * @param storage Ссылка на контроллер хранилища статических ресурсов
		 * 
		 */		
		public function ServerConnectionController(databaseConnection:DBConnection, storage:ServerResourceStorage) 
		{
			super();
			_db = databaseConnection;
			_clients = new Dictionary(true);
			_storage = storage;
			
			if (_db.connected) initHandler();
			else _db.addEventListener(Event.COMPLETE, initHandler);
			
			Logger.instance.writeLine("Server controller created");
		}
		
		/**
		 * Инициализация контроллера
		 * 
		 * @param event Событие, уведомляющее о готовности базы данных
		 * @private
		 */		
		public function initHandler(event:Event = null):void
		{
			if (event) {
				event.stopImmediatePropagation();
				(event.currentTarget as IEventDispatcher).removeEventListener(Event.COMPLETE, initHandler);
			}
			_inited = true;
			dispatchEvent(new Event(Event.INIT));
		}
		
		/**
		 * Получение данных ресурса
		 * 
		 * @param url URL-адрес или идентификатор ресурса
		 * @param callback Обработчик получения данных ресурса
		 * 
		 */		
		override public function getResource(url:String, callback:Function):void
		{
			callback(_storage.getResource(url));
		}
		
		/**
		 * Получение подключенного клиента по его сокетному соединению
		 * 
		 * @param socket Сокетное соединение
		 * @return Объект клиента
		 * 
		 */		
		public function getClient(socket:Socket):Client
		{
			return _clients[socket];
		}
		
		/**
		 * Создание и добавление нового клиента в список
		 * 
		 * @param socket Сокетное соединение
		 * 
		 */		
		public function addClient(socket:Socket):void
		{
			if (!_enabled) {
				socket.close();
				Logger.instance.writeLine("Socket closed " + socket.remoteAddress + ":" + socket.remotePort);
			}
			var client:Client = new Client(this, new User(), socket);
			_clients[socket] = client;
			socket.addEventListener(Event.CLOSE, closeClientConnectionHandler);
			Logger.instance.writeLine("Add new client " + socket.remoteAddress + ":" + socket.remotePort);
		}
		
		/**
		 * Обработчик события закрытия соединения между клиентом и сервером
		 * 
		 * @param event Событие о закрытии соединения
		 * @private
		 */		
		protected function closeClientConnectionHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			var socket:Socket = event.currentTarget as Socket;
			var client:Client = getClient(socket);
			var user:User = client.currentUser;
			if (user.id) {
				if (user.logged)
					user.update({logged:false});
				saveUserData(user);
			}
			removeClient(socket);
		}
		
		/**
		 * Удаление существующего клиента из списка
		 * 
		 * @param socket Сокетное соединение удаляемого клиента с сервером
		 * 
		 */		
		public function removeClient(socket:Socket):void
		{
			socket.removeEventListener(Event.CLOSE, closeClientConnectionHandler);
			var client:Client = getClient(socket);
			client.dispose();
			delete _clients[socket];
			Logger.instance.writeLine("Remove client " + socket.remoteAddress + ":" + socket.remotePort);
		}
		
		/**
		 * Сохранение данных о пользователе в базу данных
		 * 
		 * @param user Объект сохраняемых данных пользователя
		 * 
		 */		
		protected function saveUserData(user:User):void
		{
			_db.setObject(DBObjectTypes.USER_TYPE, user.id, user);
			//Model.instance.dropUser(user.id);
		}
		
		/**
		 * Метод удаленного вызова API сервера
		 * 
		 * @param client Клиент, выполнивший удаленный вызов
		 * @param method Запрошенный метод API
		 * @param data Данные переданные на обработку
		 * @param callback Обработчик получения результата вызова
		 * 
		 */		
		override public function call(client:Client, method:String, data:*, callback:Function):void
		{
			var result:*;
			var userID:String;
			var isClientUser:Boolean;
			switch (method) {
				case "login":
					userID = data['login'] + "_" + data['password'];
					result = getUser(client, userID, true);
					(result as User).update({logged: true});
					client.currentUser = result;
					break;
				case "getUserData":
					userID = data;
					result = getUser(client, userID);
					break;
				case "placeItem":
					result = placeItem(client, data['item_type'], data['x'], data['y']);
					break;
				case "moveItem":
					result = moveItem(client, data['id'], data['x'], data['y']);
					break;
				case "collectItem":
					result = collectItem(client, data);
					break;
				case "upgradeItems":
					result = upgradeItems(client, data);
					if (!result || !data || result.length != data.length)
						result = null;
					break;
				default:
					result = data;
					callback(getErrorMessage(UserError.METHOD_NOT_AVAILABLE));
					return;
			}
			if (result)
				callback(result);
			else
				callback(getErrorMessage(UserError.G_CALL_ABORTED));
		}
		
		/**
		 * Получение объекта пользователя по его идентификатору
		 * 
		 * @param client Клиент, запрашивающий данные
		 * @param userID Идентификатор пользователя, о котором требуется получить данные
		 * @param isClientUser Флаг, свидетельствует о том, что в случае отсутствия объекта
		 * пользователя на сервере, требуется не создавать нового пользователя, а взять объект
		 * из объекта клиента (см. код)
		 * @return Объект пользователя
		 * 
		 */		
		protected function getUser(client:Client, userID:String, isClientUser:Boolean = false):User
		{
			var result:*;
			var user:User = Model.instance.getUser(userID);
			if (user)
				return user;
			result = _db.getObject(DBObjectTypes.USER_TYPE, userID);
			user = isClientUser ? client.currentUser : new User();
			if (!result) {
				user.update({id: userID});
				_db.setObject(DBObjectTypes.USER_TYPE, userID, user);
			} else {
				user.update(result);
			}
			Model.instance.addUser(user);
			return user;
		}
		
		/**
		 * Подготовка сообщения об ошибке для клиента
		 * 
		 * @param errorCode Код серверной ошибки
		 * @return Объект сообщения об ошибке
		 * 
		 */		
		protected function getErrorMessage(errorCode:int):Object
		{
			return { "error": UserError.getErrorData(errorCode) };
		}
	}

}