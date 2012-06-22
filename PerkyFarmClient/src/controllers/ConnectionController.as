package controllers 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
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
		
		// установка нового объекта в заданное место на карте пользователя
		protected function _placeItem(client:Client, itemType:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return false;
			if (user.addItem(itemType, xpos, ypos)) {
				client.connection.send("placeItem", { item_type: itemType, x: xpos, y: ypos }, callback);
				return true;
			}
			return false;
		}
		
		// перемещение объекта в заданное место на карте пользователя
		protected function _moveItem(client:Client, itemID:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return false;
			if (user.moveItem(itemID, xpos, ypos)) {
				client.connection.send("moveItem", { id: itemID, x: xpos, y: ypos }, callback);
				return true;
			}
			return false;
		}
		
		// сбор готового объекта
		protected function _collectItem(client:Client, itemID:String, callback:Function):Boolean
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return false;
			if (user.collectItem(itemID)) {
				client.connection.send("collectItem", { id: itemID }, callback);
				return true;
			}
			return false;
		}
		
		// инкремент уровня всех объектов на карте пользователя
		protected function _upgradeAllItems(client:Client, callback:Function):Boolean
		{
			var user:User = client.currentUser;
			if (!user || !user.id) return false;
			var itemIDs:Array = user.getAllItemIDs();
			if (itemIDs.length == 0) return true;
			var upgradedItems:Array = user.upgradeItems(itemIDs);
			if (upgradedItems.length > 0)
				client.connection.send("upgradeAllItems", upgradedItems, callback);
			return true;
		}
		
		// получение запроса от сервера
		public function call(client:Client, method:String, data:Object, callback:Function):void 
		{
			throw("Abstract method call(method:String, data:Object, callback:Function) must be overriden");
		}
	}
}