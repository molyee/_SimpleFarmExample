package api
{
	import data.DBConnection;
	
	import errors.UserError;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import logging.Logger;
	
	import models.Model;
	import models.User;
	
	import net.connection.Client;

	// интерфейс пользовательского сервера
	public class UserAPI
	{
		// ссылка на приложение
		private var _application:FarmServer;
		// ссылка на модель
		private var _model:Model;
		// ссылка на контроллер базы данных
		private var _db:DBConnection;
		
		// валидатор данных
		public var validator:APIValidator;
		
		// триггер доступности API
		private var _enabled:Boolean;
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void { // устанавливается извне при соблюдении всех условий
			if (_enabled == value) return;
			_enabled = value;
			if (_enabled)
				Logger.instance.writeLine("UserAPI enabled");
			else
				Logger.instance.writeLine("UserAPI disabled");
		}
		
		// -- конструктор
		public function UserAPI(application:FarmServer, dbConnection:DBConnection)
		{
			validator = new APIValidator();
			_application = application;
			_db = dbConnection;
			_model = Model.instance;
			
			Logger.instance.writeLine("UserAPI created");
		}
		
		// процессор авторизации
		public function login(user:User, data:*, callback:Function):void
		{
			if (!data || !data['login'] || !data['password']) {
				// переданы неверные данные
				callback(getErrorMessage(UserError.WRONG_ARGUMENTS));
				Logger.instance.writeLine("Login failed " + user.ipv4);
				return;
			}
			var login:String = String(data['login']);
			var password:String = String(data['password']);
			
			Logger.instance.writeLine("Login success " + user.ipv4);
		}
		
		// процессор деавторизации
		public function logout(user:User, callback:Function):void
		{
			Logger.instance.write("Logout success " + user.ipv4);
		}
		
		// процессор добавления объекта карты
		public function addItem(user:User, data:*, callback:Function):void
		{
			if (!validator.checkPermissions(user)) {
				callback(getErrorMessage(UserError.ACCESS_DENIED));
				Logger.instance.writeLine("AddItem failed " + user.ipv4);
				return;
			}
			Logger.instance.writeLine("AddItem success User_" + user.id + " " + user.ipv4);
		}
		
		// процессор удаления объекта карты
		public function removeItem(user:User, data:*, callback:Function):void
		{
			if (!validator.checkPermissions(user)) {
				callback(getErrorMessage(UserError.ACCESS_DENIED));
				Logger.instance.writeLine("RemoveItem failed " + user.ipv4);
				return;
			}
			Logger.instance.writeLine("RemoveItem success User_" + user.id + " " + user.ipv4);
		}
		
		// процессор инкремента уровня всех объектов карты
		public function upgradeAllItems(user:User, callback:Function):void
		{
			if (!validator.checkPermissions(user)) {
				callback(getErrorMessage(UserError.ACCESS_DENIED));
				Logger.instance.writeLine("UpgradeAllItems failed " + user.ipv4);
				return;
			}
			Logger.instance.writeLine("UpgradeAllItems success User_" + user.id + " " + user.ipv4);
		}
		
		// процессор перемещения объекта карты
		public function moveItem(user:User, data:*, callback:Function):void
		{
			if (!validator.checkPermissions(user)) {
				callback(getErrorMessage(UserError.ACCESS_DENIED));
				Logger.instance.writeLine("MoveItem failed " + user.ipv4);
				return;
			}
			Logger.instance.writeLine("MoveItem success User_" + user.id + " " + user.ipv4);
		}
		
		// вызов API для удаленных клиентов (ограничения)
		public function call(user:User, method:String, data:*, callback:Function):void
		{
			if (!user.logged) { // если пользователь не авторизован
				if (method == "login" && data != null) {
					login(user, data, callback); // если вызван процессор авторизации
				} else {
					var errorCode:int = UserError.ACCESS_DENIED;
					Logger.instance.write("ERROR " + String(errorCode) + 
						":"	+ UserError.getMessage(errorCode) + ", Action failed " + user.ipv4);
					
					callback(getErrorMessage(UserError.ACCESS_DENIED)); // иные действия запрещены
				}
				return;
			}
			switch (method) { // список разрешенных функций
				case "addItem":
					addItem(user, data, callback);
					break;
				case "removeItem":
					removeItem(user, data, callback);
					break;
				case "upgradeAllItems":
					upgradeAllItems(user, callback);
					break;
				case "moveItem":
					moveItem(user, data, callback);
					break;
				default: // сообщение об ошибке, если вызов не разрешен или неизвестен
					errorCode = UserError.METHOD_NOT_AVAILABLE;
					Logger.instance.write("ERROR " + String(errorCode) + 
						":"	+ UserError.getMessage(errorCode) + ", Action failed " + user.ipv4);
					callback(getErrorMessage(UserError.METHOD_NOT_AVAILABLE));
			}
		}
		
		// подготовка сообщения об ошибке
		private function getErrorMessage(errorCode:int):Object
		{
			return { "error": UserError.getErrorData(errorCode) };
		}
	}
}