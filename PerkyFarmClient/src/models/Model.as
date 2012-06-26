package models
{
	import controllers.IConnectionController;
	
	import events.ObjectEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import models.Item;

	// события, генерируемые объектами класса
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	[Event(name="init", type="flash.events.Event")]
	[Event(name="userAdded", type="models.Model")]
	[Event(name="userRemoved", type="models.Model")]
	public class Model extends EventDispatcher
	{
		public static const USER_ADDED:String = "userAdded";
		public static const USER_REMOVED:String = "userRemoved";
		
		// -- экземпляр-одиночка модели
		public static const instance:Model = new Model();
		
		// ссылка на контроллер обмена данными
		private var _controller:IConnectionController;
		
		// список пользователей подгруженных из базы данных
		private var _users:Object;
		
		// данные о типах объектов
		private var _itemsConfigLoaded:Boolean; // триггер готовности данных о типах объектов
		
		// триггер готовности модели
		private var _inited:Boolean;
		public function get inited():Boolean { return _inited; }
		
		// -- конструктор
		public function Model()
		{
			if (Model) throw("Model is singleton, construction unavailable");
		}
		
		// получение связи с контроллером данных
		public function init(controller:IConnectionController):void
		{
			_users = { };
			_controller = controller;
			_controller.getResource(Settings.ITEMS_CONFIG_URL, initItemTypesHandler);
			if (_controller.inited) initControllerHandler();
			else _controller.addEventListener(Event.INIT, initControllerHandler);
		}
		
		// обработчик события готовности контроллера данных (запуск модели)
		private function initControllerHandler(event:Event = null):void
		{
			if (event) {
				(event.currentTarget as EventDispatcher).removeEventListener(Event.COMPLETE, initControllerHandler);
				event.stopImmediatePropagation();
			}
			checkCompleteInitialization();
		}
		
		// обработчик получения данных о типах объектов
		private function initItemTypesHandler(data:XML):void
		{
			ItemType.initItemTypes(data);
			_itemsConfigLoaded = true;
			checkCompleteInitialization();
		}
		
		// проверка условий завершения инициализации модели
		private function checkCompleteInitialization():Boolean
		{
			if (_inited) return true;
			if (!_controller || !_controller.inited || !_itemsConfigLoaded)
				return false;
			_inited = true;
			dispatchEvent(new Event(Event.INIT));
			return true;
		}
		
		// получение данных пользователя
		public function getUser(userID:String):User
		{
			return _users[userID] as User;
		}
		
		// создание нового пользователя
		public function addUser(user:User):void
		{
			_users[user.id] = user;
			dispatchEvent(new ObjectEvent(USER_ADDED, user));
		}
		
		// обновление данных пользователя
		public function updateUser(userID:String, changes:Object):Boolean
		{
			var user:User = getUser(userID);
			if (!user || !user.update(changes))
				return false;
			return true;
		}
		
		// удаление пользователя
		public function dropUser(userID:String):Boolean
		{
			var user:User = _users[userID];
			if (!user)
				return false;
			user.dispose();
			delete _users[userID];
			dispatchEvent(new ObjectEvent(USER_REMOVED, user));
			return true;
		}
		
		// получение данных о типах объектов
		public function getItemTypes():Object
		{
			if (!_inited)
				throw("Model is not initialized yet");
			return ItemType.ITEM_TYPES;
		}
	}
}