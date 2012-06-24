package controllers 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import models.Item;
	import models.Model;
	
	import models.User;
	
	import net.connection.Client;
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ConnectionController extends EventDispatcher implements IConnectionController 
	{
		// триггер готовности контроллера
		protected var _inited:Boolean;
		public function get inited():Boolean { return _inited; }
		
		
		// -- конструктор
		public function ConnectionController() 
		{
		}
		
		// получение данных ресурса
		public function getResource(url:String, callback:Function):void
		{
			throw("Abstract method getResource(url:String, callback:Function) must be overriden");
		}
		
		// получение данных о пользователе
		public function getUserData(userID:String, callback:Function):void
		{
			throw("Abstract method getUserData(userID:String, callback:Function) must be overriden");
		}
		
		// получение данных об объекте на карте пользователя
		public function getItem(userID:String, itemID:String, callback:Function):Boolean
		{
			var user:User = Model.instance.getUser(userID);
			if (!user || !user.id) return false;
			var item:Item = user.getItem(itemID);
			if (item != null) {
				callback(item);
				return true;
			}
			return false;
		}
		
		// получение данных о типе объекта на карте
		public function getItemTypeData(itemType:String, callback:Function):void
		{
			throw("Abstract method getItemTypeData(itemType:String, callback:Function) must be overriden");
		}
		
		// получение данных о типах объектов
		public function getItemTypes(callback:Function):void
		{
			throw("Abstract method getItemTypes(callback:Function) must be overriden");
		}
		
		// ------ user api
		
		// установка нового объекта в заданное место на карте пользователя
		public function placeItem(client:Client, itemType:String, xpos:int, ypos:int, callback:Function):String
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return null;
			return user.addItem(itemType, xpos, ypos);
		}
		
		// перемещение объекта в заданное место на карте пользователя
		public function moveItem(client:Client, itemID:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return false;
			return user.moveItem(itemID, xpos, ypos);
		}
		
		// сбор готового объекта
		public function collectItem(client:Client, itemID:String, callback:Function):Boolean
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return false;
			return user.collectItem(itemID);
		}
		
		// инкремент уровня всех объектов на карте пользователя
		public function upgradeItems(client:Client, itemIDs:Array, callback:Function):Array
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return null;
			var itemIDs:Array = itemIDs || user.getAllItemIDs();
			if (itemIDs.length == 0) return itemIDs;
			var upgradedItems:Array = user.upgradeItems(itemIDs);
			return upgradedItems;
		}
		
		// получение запроса от сервера
		public function call(client:Client, method:String, data:*, callback:Function):void 
		{
			throw("Abstract method call(method:String, data:Object, callback:Function) must be overriden");
		}
	}
}