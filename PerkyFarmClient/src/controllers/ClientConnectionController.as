package controllers
{
	import display.ResourceStorage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import models.Item;
	import models.ItemType;
	import models.Model;
	import models.User;
	
	import net.connection.Client;
	
	/**
	 * Контроллер клиентской части приложения, обеспечивающего связь между моделью данных и визуализацией,
	 * а также обеспечивающего асинхронный обмен данными между клиентом и сервером.
	 * ...
	 * @author Alex Sarapulov
	 */
	[Event(name="connect", type="flash.events.Event")]
	[Event(name="init", type="flash.events.Event")]
	[Event(name="close", type="flash.events.Event")]
	public class ClientConnectionController extends ConnectionController
	{
		/**
		 * Триггер соединения с удаленным объектом
		 * 
		 */
		public function get connected():Boolean {
			var result:Boolean = false;
			try {
				result = _client.connection.protocol.isOpen;
			} catch (e:Error) { }
			return result;
		}
		
		/**
		 * Ссылка на хранилище статических ресурсов
		 * @private
		 */
		protected var _resourceStorage:ResourceStorage;
		
		protected var _client:Client;
		/**
		 * Объект контроля соединения
		 * 
		 */
		public function get client():Client { return _client; }
		
		/**
		 * Конструктор клиентского контроллера
		 * 
		 */
		public function ClientConnectionController()
		{
			_client = new Client(this, new User(), null, true);
			_resourceStorage = new ResourceStorage();
			super();
		}
		
		/**
		 * Создание соединения с сервером
		 * 
		 * @param	host Наименование хоста удаленного сервера
		 * @param	port Номер порта подключения
		 * 
		 */
		public function connect(host:String, port:int):void
		{
			_client.connection.protocol.addEventListener(Event.CONNECT, connectHandler);
			_client.connection.protocol.addEventListener(Event.CLOSE, closeHandler);
			_client.connection.connect(host, port);
		}
		
		/**
		 * Обработчик события получения соединения с удаленным объектом
		 * 
		 * @param	event Событие, информирующее о подключении к серверу
		 * @private
		 */
		protected function connectHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			(event.currentTarget as IEventDispatcher).removeEventListener(Event.CONNECT, connectHandler);
			dispatchEvent(new Event(Event.CONNECT));
		}
		
		/**
		 * Обработчик события потери соединения с сервером
		 * 
		 * @param	event Событие, информирующее о потере подключения с сервером
		 */
		protected function closeHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			(event.currentTarget as IEventDispatcher).removeEventListener(Event.CONNECT, connectHandler);
			(event.currentTarget as IEventDispatcher).removeEventListener(Event.CLOSE, closeHandler);
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		// -- request senders
		
		/**
		 * Обработчик результата авторизации на сервере
		 * @private
		 */
		protected var _loginHandler:Function;
		/**
		 * Триггер ожидания авторизации, свидетельствующий о состоянии клиента, который отправил запрос на авторизацию,
		 * но при этом еще не получил ответ от сервера
		 * @private
		 */
		protected var _logging:Boolean = false;
		
		/**
		 * Авторизация пользователя
		 * 
		 * @param	login Логин пользователя
		 * @param	password Пароль пользователя
		 * @param	loginHandler Обработчик получения результатов авторизации
		 */
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
		
		/**
		 * Внутренний обработчик получения результата авторизации
		 * 
		 * @param	result Полученые данные с сервера
		 * @private
		 */
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
			_client.currentUser.update(result);
			dispatchEvent(new Event(Event.INIT));
		}
		
		/**
		 * Получение статического ресурса c сервера
		 * 
		 * @param url URL-адрес ресурса, одновременно являющийся его идентификатором
		 * @param callback Обработчик, получающий данные о запрашиваемом ресурсе
		 * @private
		 */
		override public function getResource(url:String, callback:Function):void
		{
			_resourceStorage.getResource(url, callback);
		}
		
		/**
		 * Получение данных о пользователе
		 * 
		 * @param userID Уникальный идентификатор пользователя, о котором требуется получить
		 * информацию
		 * @param callback Обработчик, получающий данные о запрошенном пользователе
		 * @private
		 */	
		public function getUserData(userID:String, callback:Function):void
		{
			_client.connection.send("getUserData", userID, callback);
		}
		
		/**
		 * Получение данных об объекте на карте пользователя
		 * 
		 * @param userID Идентификатор пользователя, являющегося владельцем объекта
		 * @param itemID Уникальный идентификатор объекта, расположенного на карте пользователя
		 * @param callback Обработчик, получающий данные об объекте карты
		 * @return Результат первичной валидации данных
		 * 
		 */
		public function getItem(userID:String, itemID:String, callback:Function):Boolean
		{
			var user:User = userID != null ? Model.instance.getUser(userID) : _client.currentUser;
			if (!user || !user.id) return false;
			var item:Item = user.getItem(itemID);
			if (item != null) {
				callback(item);
				return true;
			}
			return false;
		}
		
		/**
		 * Получение данных о типе (шаблоне) объекта
		 * 
		 * @param itemType Наименование типа объекта
		 * @param callback Обработчик, получающий данные о шаблоне объекта
		 * @private
		 */
		public function getItemTypeData(itemType:String, callback:Function):void
		{
			callback(ItemType.getItemTypeData(itemType));
		}
		
		/**
		 * Получение данных о всех типах (шаблонах) объектов
		 * 
		 * @param callback Обработчик, получающий данные о типах объектов
		 * @private
		 */	
		public function getItemTypes(callback:Function):void
		{
			callback(Model.instance.getItemTypes());
		}
		
		// ------ user api ------
		
		/**
		 * Создание нового объекта и установка его в указанную точку на карте пользователя
		 * 
		 * @param client Объект клиента, сгенерировавшего запрос (необходим для получения данных о пользователе)
		 * @param itemType Наименование типа (шаблона) создаваемого объекта
		 * @param xpos Значение позиции X установки объекта на карту (координата тайла)
		 * @param ypos Значение позиции Y установки объекта на карту (координата тайла)
		 * @param callback Обработчик, получающий результат действий создания и установки объекта
		 * @return Идентификатор созданного объекта возвращается при успешном выполнении операции
		 * 
		 */	
		public function tryPlaceItem(itemType:String, xpos:int, ypos:int, callback:Function):String
		{
			var res:String = super.placeItem(_client, itemType, xpos, ypos);
			if (res != null) _client.connection.send("placeItem", { item_type: itemType, x: xpos, y: ypos }, callback);
			return res;
		}
		
		/**
		 * Перемещение существующего объекта в указанную точку на карте пользователя
		 * 
		 * @param itemID Идентификатор объекта карты пользователя
		 * @param xpos Значение позиции X установки объекта на карту (координата тайла)
		 * @param ypos Значение позиции Y установки объекта на карту (координата тайла)
		 * @param callback Обработчик, получающий результат перемещения объекта в указанную точку
		 * @return Идентификатор созданного объекта возвращается при успешном выполнении операции,
		 * в ином случае возвращается null
		 * 
		 */
		public function tryMoveItem(itemID:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			var res:Boolean = super.moveItem(_client, itemID, xpos, ypos);
			if (res) _client.connection.send("moveItem", { id: itemID, x: xpos, y: ypos }, callback);
			return res;
		}
		
		/**
		 * Сбор подготовленного объекта с карты пользователя и помещение его в инвентарь пользователя
		 * 
		 * @param itemID Идентификатор объекта карты пользователя
		 * @param callback Обработчик, получающий результат удаления объекта с карты и помещения его в инвентарь
		 * @return Флаг успешного выполнения функции сбора объекта
		 * 
		 */
		public function tryCollectItem(itemID:String, callback:Function):Boolean
		{
			var res:Boolean = super.collectItem(_client, itemID);
			if (res) _client.connection.send("collectItem", itemID, callback);
			return res;
		}
		
		/**
		 * Инкремент уровня объектов карты
		 * 
		 * @param itemIDs Список идентификаторов объектов, требующих применения инкремента уровня,
		 * если список равен null, то процедура выполняет инкремент для всех объектов, для которых доступно
		 * такое действие, возвращая список идентификаторов объектов, над которыми процедура была выполнена успешно
		 * @param callback Обработчик, получающий результат выполнения процедуры инкремента уровня
		 * @return Список идентификаторов объектов, к которым была успешно применена процедура инкремента уровня
		 * 
		 */
		public function tryUpgradeItems(itemIDs:Array, callback:Function):Array
		{
			var res:Array = super.upgradeItems(_client, itemIDs) as Array;
			if (res && res.length > 0)
				_client.connection.send("upgradeItems", res, callback);
			return res;
		}
		
		// -- request handlers
		
		/**
		 * Удаленный вызов метода с сервера
		 * 
		 * @param client Объект целевого клиента (необходим для получения данных о пользователе
		 * и данных о соединении пользователя)
		 * @param method Наименование вызываемого метода
		 * @param data Данные передаваемые методу
		 * @param callback Обработчик, ожидающий получения результата выполнения запроса
		 * @private
		 */
		override public function call(client:Client, method:String, data:*, callback:Function):void
		{
			// TODO(Alex Sarapulov): make handler
			trace("get some request");
			callback(data);
		}
		
	}
}