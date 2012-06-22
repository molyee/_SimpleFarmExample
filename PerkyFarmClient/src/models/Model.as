package models
{
	import controllers.IConnectionController;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import models.Item;

	// события, генерируемые объектами класса
	[Event(name="init", type="flash.events.Event")]
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class Model extends EventDispatcher
	{
		// -- экземпляр-одиночка модели
		public static const instance:Model = new Model();
		
		// ссылка на контроллер обмена данными
		private var _controller:IConnectionController;
		
		// список пользователей подгруженных из базы данных
		private var _users:Object;
		
		// триггер готовности модели
		public function get inited():Boolean {
			return _controller != null && _controller.inited;
		}
		
		// -- конструктор
		public function Model()
		{
			if (Model) throw("Model is singleton, construction unavailable");
		}
		
		// получение связи с контроллером данных
		public function init(controller:IConnectionController):void
		{
			_users = {};
			_controller = controller;
			if (inited) initHandler();
			else _controller.addEventListener(Event.INIT, initHandler);
		}
		
		// обработчик готовности контроллера данных (запуск модели)
		private function initHandler(event:Event = null):void
		{
			if (event) {
				(event.currentTarget as EventDispatcher).removeEventListener(Event.COMPLETE, initHandler);
				event.stopImmediatePropagation();
			}
			dispatchEvent(new Event(Event.INIT));
		}
		
		// получение данных пользователя
		public function getUser(userID:String):User
		{
			return _users[userID] as User;
		}
		
		// создание нового пользователя
		public function addUser():User
		{
			var user:User = new User();
			_users[user.id] = user;
			return user;
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
			return true;
		}
	}
}