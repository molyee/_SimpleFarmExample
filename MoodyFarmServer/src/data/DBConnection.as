package data
{
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.SharedObject;
	
	import logging.Logger;
	
	import models.User;

	[Event(name="complete", type="flash.events.Event")]
	public class DBConnection extends EventDispatcher
	{
		private var users:SharedObject;
		private var items:SharedObject;
		private var authData:SharedObject;
		
		private var _connected:Boolean;
		public function get connected():Boolean { return _connected; }
		
		public function DBConnection()
		{
			users = SharedObject.getLocal("users");
			users.clear();
			users.client = this;
			users.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorEventHandler);
			users.addEventListener(SyncEvent.SYNC, syncEventHandler);
			users.addEventListener(NetStatusEvent.NET_STATUS, netStatusEventHandler);
			
			items = SharedObject.getLocal("items");
			items.clear();
			items.client = this;
			items.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorEventHandler);
			items.addEventListener(SyncEvent.SYNC, syncEventHandler);
			items.addEventListener(NetStatusEvent.NET_STATUS, netStatusEventHandler);
			
			initCompleteHandler();
		}
		
		private function initCompleteHandler():void
		{
			_connected = true;
			dispatchEvent(new Event(Event.COMPLETE));
			Logger.instance.writeLine("Database connected");
		}
		
		private function getDB(objectType:String):SharedObject
		{
			switch (objectType) {
				case DBObjectTypes.USER_TYPE:
					return users;
				case DBObjectTypes.ITEM_TYPE:
					return items;
			}
			return null;
		}
		
		public function addObject(objectType:String, data:Object):Object
		{
			var currentID:int = int(authData.data[objectType]);
			currentID++;
			authData.setProperty(objectType, currentID);
			var id:String = currentID.toString();
			data["id"] = id;
			var so:SharedObject = getDB(objectType);
			so.setProperty(id, data);
			return data;
		}
		
		public function getObject(objectType:String, objectKey:String):Object
		{
			var so:SharedObject = getDB(objectType);
			return so.data[objectKey];
		}
		
		public function setObject(objectType:String, objectKey:String, data:Object):void
		{
			var so:SharedObject = getDB(objectType);
			so.setProperty(objectKey, data);
		}
		
		private function asyncErrorEventHandler(event:AsyncErrorEvent):void
		{
			trace(event);
		}
		
		private function syncEventHandler(event:SyncEvent):void
		{
			trace(event);
		}
		
		private function netStatusEventHandler(event:NetStatusEvent):void
		{
			trace(event);
		}
		
		public function finalize():void
		{
			
		}
	}
}