package controllers 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import models.Item;
	import models.Model;
	
	import models.User;
	
	import net.connection.Client;
	
	/**
	 * Контроллер приложения, обеспечивающего связь между моделью данных и визуализацией,
	 * а также обеспечивающего асинхронный обмен данными между клиентом и сервером.
	 * Использовать как абстрактный класс
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ConnectionController extends EventDispatcher implements IConnectionController 
	{
		protected var _inited:Boolean;
		/**
		 * Триггер готовности контроллера
		 * 
		 */
		public function get inited():Boolean { return _inited; }
		
		
		/**
		 * Конструктор контроллера соединения
		 * 
		 */
		public function ConnectionController()
		{
			
		}
		
		/**
		 * Получение статического ресурса c сервера
		 * 
		 * @param url URL-адрес ресурса, одновременно являющийся его идентификатором
		 * @param callback Обработчик, получающий данные о запрашиваемом ресурсе
		 * @private
		 */
		public function getResource(url:String, callback:Function):void
		{
			throw("Abstract method getResource(url:String, callback:Function) must be overriden");
		}
		
		// ------ user api
		
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
		public function placeItem(client:Client, itemType:String, xpos:int, ypos:int):String
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return null;
			return user.addItem(itemType, xpos, ypos);
		}
		
		/**
		 * Перемещение существующего объекта в указанную точку на карте пользователя
		 * 
		 * @param client Объект клиента, сгенерировавшего запрос (необходим для получения данных о пользователе)
		 * @param itemID Идентификатор объекта карты пользователя
		 * @param xpos Значение позиции X установки объекта на карту (координата тайла)
		 * @param ypos Значение позиции Y установки объекта на карту (координата тайла)
		 * @param callback Обработчик, получающий результат перемещения объекта в указанную точку
		 * @return Идентификатор созданного объекта возвращается при успешном выполнении операции,
		 * в ином случае возвращается null
		 * 
		 */
		public function moveItem(client:Client, itemID:String, xpos:int, ypos:int):Boolean
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return false;
			return user.moveItem(itemID, xpos, ypos);
		}
		
		/**
		 * Сбор подготовленного объекта с карты пользователя и помещение его в инвентарь пользователя
		 * 
		 * @param client Объект клиента, сгенерировавшего запрос (необходим для получения данных о пользователе)
		 * @param itemID Идентификатор объекта карты пользователя
		 * @param callback Обработчик, получающий результат удаления объекта с карты и помещения его в инвентарь
		 * @return Флаг успешного выполнения функции сбора объекта
		 * 
		 */
		public function collectItem(client:Client, itemID:String):Boolean
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return false;
			return user.collectItem(itemID);
		}
		
		/**
		 * Инкремент уровня объектов карты
		 * 
		 * @param client Объект клиента, сгенерировавшего запрос (необходим для получения данных о пользователе)
		 * @param itemIDs Список идентификаторов объектов, требующих применения инкремента уровня,
		 * если список равен null, то процедура выполняет инкремент для всех объектов, для которых доступно
		 * такое действие, возвращая список идентификаторов объектов, над которыми процедура была выполнена успешно
		 * @return Список идентификаторов объектов, к которым была успешно применена процедура инкремента уровня
		 * 
		 */	
		public function upgradeItems(client:Client, itemIDs:Array):Array
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return null;
			var itemIDs:Array = itemIDs || user.getAllItemIDs();
			if (itemIDs.length == 0) return itemIDs;
			var upgradedItems:Array = user.upgradeItems(itemIDs);
			return upgradedItems;
		}
		
		/**
		 * Удаленный вызов метода контроллера с ограничением, обозначенным классом, реализующим интерфейс
		 * 
		 * @param client Объект целевого клиента (необходим для получения данных о пользователе
		 * и данных о соединении пользователя)
		 * @param method Наименование вызываемого метода
		 * @param data Данные передаваемые методу
		 * @param callback Обработчик, ожидающий получения результата выполнения запроса
		 * @private
		 */
		public function call(client:Client, method:String, data:*, callback:Function):void 
		{
			throw("Abstract method call(method:String, data:Object, callback:Function) must be overriden");
		}
	}
}