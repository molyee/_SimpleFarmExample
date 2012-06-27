package models
{
	import controllers.IConnectionController;
	
	import events.ObjectEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import models.Item;

	/**
	 * Основной класс модели данных
	 * 
	 * ...
	 * @author Alex Sarapulov
	 */
	[Event(name="init", type="flash.events.Event")]
	[Event(name="userAdded", type="models.Model")]
	[Event(name="userRemoved", type="models.Model")]
	public class Model extends EventDispatcher
	{
		/** Константа наименования события о добавлении пользователя */
		public static const USER_ADDED:String = "userAdded";
		/**	Константа наименования события о удалении пользователя */
		public static const USER_REMOVED:String = "userRemoved";
		
		/**
		 * Размер карты в ячейках (на одну сторону)
		 */
		public static const MAP_SIZE:int = 30;
		
		/**
		 * Экземпляр-одиночка модели
		 * 
		 */
		public static const instance:Model = new Model();
		
		/**
		 * Ссылка на контроллер обмена данными
		 * @private
		 */
		private var _controller:IConnectionController;
		
		/**
		 * Список пользователей подгруженных из базы данных
		 * @private
		 */
		private var _users:Object;
		
		/**
		 * Триггер готовности данных о типах объектов
		 * @private
		 */
		private var _itemsConfigLoaded:Boolean;
		
		private var _inited:Boolean;
		/**
		 * Триггер готовности модели
		 * 
		 */
		public function get inited():Boolean { return _inited; }
		
		/**
		 * Конструктор модели
		 * 
		 */
		public function Model()
		{
			if (Model) throw("Model is singleton, construction unavailable");
		}
		
		/**
		 * Получение связи с контроллером приложения
		 * 
		 * @param	controller Ссылка на контроллер приложения
		 */
		public function init(controller:IConnectionController):void
		{
			_users = { };
			_controller = controller;
			_controller.getResource(Settings.ITEMS_CONFIG_URL, initItemTypesHandler);
			if (_controller.inited) initControllerHandler();
			else _controller.addEventListener(Event.INIT, initControllerHandler);
		}
		
		/**
		 * Обработчик события готовности контроллера приложения (запуск модели)
		 * 
		 * @param	event Событие, уведомляющее о готовности контроллера
		 * @private
		 */
		private function initControllerHandler(event:Event = null):void
		{
			if (event) {
				(event.currentTarget as EventDispatcher).removeEventListener(Event.COMPLETE, initControllerHandler);
				event.stopImmediatePropagation();
			}
			checkCompleteInitialization();
		}
		
		/**
		 * Обработчик получения данных о типах объектов
		 * @private
		 */
		private function initItemTypesHandler(data:XML):void
		{
			ItemType.initItemTypes(data);
			_itemsConfigLoaded = true;
			checkCompleteInitialization();
		}
		
		/**
		 * Проверка условий завершения инициализации модели
		 * 
		 * @return Флаг готовности модели
		 */
		private function checkCompleteInitialization():Boolean
		{
			if (_inited) return true;
			if (!_controller || !_controller.inited || !_itemsConfigLoaded)
				return false;
			_inited = true;
			dispatchEvent(new Event(Event.INIT));
			return true;
		}
		
		/**
		 * Получение данных пользователя по его идентификатору
		 * 
		 * @param	userID Идентификатор пользователя
		 * @return Объект пользователя
		 */
		public function getUser(userID:String):User
		{
			return _users[userID] as User;
		}
		
		/**
		 * Добавление нового пользователя
		 * 
		 * @param	user Добавляемый объект пользователя
		 */
		public function addUser(user:User):void
		{
			_users[user.id] = user;
			dispatchEvent(new ObjectEvent(USER_ADDED, user));
		}
		
		/**
		 * Обновление данных пользователя
		 * 
		 * @param	userID Идентификатор пользователя
		 * @param	changes Изменения данных пользователя
		 * @return Результат выполнения обновления данных, true - выполнено успешно
		 */
		public function updateUser(userID:String, changes:Object):Boolean
		{
			var user:User = getUser(userID);
			if (!user || !user.update(changes))
				return false;
			return true;
		}
		
		/**
		 * Удаление пользователя
		 * 
		 * @param	userID Идентификатор пользователя
		 * @return Результат выполнения идаления пользователя, true - пользователь удален
		 */
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
		
		/**
		 * Получение размера карты
		 * 
		 * @return Размер квадратной карты в количестве ячеек на сторону квадрата
		 */
		public function getMapSize():int
		{
			return MAP_SIZE;
		}
		
		/**
		 * Получение данных о типах объектов
		 * 
		 * @return Данные о типах объектов карты
		 */
		public function getItemTypes():Object
		{
			if (!_inited)
				throw("Model is not initialized yet");
			return ItemType.ITEM_TYPES;
		}
	}
}