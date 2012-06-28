package database
{
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.SharedObject;
	
	import logging.Logger;
	
	import models.User;

	/**
	 * Класс контроллера базы данных
	 * ...
	 * @author Alex Sarapulov
	 */	
	[Event(name="complete", type="flash.events.Event")]
	public class DBConnection extends EventDispatcher
	{
		/**
		 * База данных пользователей
		 * @private
		 */		
		private var users:SharedObject;
		
		/**
		 * База данных объектов карт (в новой версии не используется)
		 * @private
		 */		
		private var items:SharedObject;
		
		/**
		 * База данных об авторизации пользователей (в новой версии не используется)
		 * @private
		 */		
		private var authData:SharedObject;
		
		private var _connected:Boolean;
		/**
		 * Триггер наличия подключения к базе данных
		 * 
		 */		
		public function get connected():Boolean { return _connected; }
		
		/**
		 * Конструктор контроллера базы данных
		 * 
		 */		
		public function DBConnection()
		{
			users = SharedObject.getLocal("users");
			/*CONFIG::debug {
				users.clear();
			}*/
			users.client = this;
			users.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorEventHandler);
			users.addEventListener(SyncEvent.SYNC, syncEventHandler);
			users.addEventListener(NetStatusEvent.NET_STATUS, netStatusEventHandler);
			
			items = SharedObject.getLocal("items");
			/*CONFIG::debug {
				items.clear();
			}*/
			items.client = this;
			items.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorEventHandler);
			items.addEventListener(SyncEvent.SYNC, syncEventHandler);
			items.addEventListener(NetStatusEvent.NET_STATUS, netStatusEventHandler);
			
			initCompleteHandler();
		}
		
		/**
		 * Обработчик завершения инициализации базы данных
		 * 
		 */		
		private function initCompleteHandler():void
		{
			_connected = true;
			dispatchEvent(new Event(Event.COMPLETE));
			Logger.instance.writeLine("Database connected");
		}
		
		/**
		 * Получение базы данных по типу хранимых объектов
		 * (в новой версии используется только база данных
		 * пользователей, в ней же хранятся данные об объектах
		 * на карте пользователей и в инвентаре пользователей)
		 * 
		 * @param objectType Тип объекта
		 * @return Ссылка на соединение с базой данных
		 * 
		 */		
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
		
		/**
		 * Добавление данных в базу (в новой версии не используется)
		 * 
		 * @param objectType Тип хранимого объекта
		 * @param data Данные объекта
		 * @return Объект с инициализированным идентификатором
		 * @private
		 */		
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
		
		/**
		 * Получение объекта из базы
		 * 
		 * @param objectType Тип объекта
		 * @param objectKey Ключ объекта (идентификатор)
		 * @return Хранимые данные об объекте
		 * 
		 */		
		public function getObject(objectType:String, objectKey:String):Object
		{
			var so:SharedObject = getDB(objectType);
			return so.data[objectKey];
		}
		
		/**
		 * Установка новых данных об объекте
		 * 
		 * @param objectType Тип объекта
		 * @param objectKey Ключ объекта (идентификатор)
		 * @param data Сохраняемые данные
		 * 
		 */		
		public function setObject(objectType:String, objectKey:String, data:Object):void
		{
			var so:SharedObject = getDB(objectType);
			so.setProperty(objectKey, data);
		}
		
		// -- обработчики обмена данными с локальным хранилищем
		
		
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
		
		/**
		 * Финализатор контроллера базы данных
		 * 
		 */		
		public function finalize():void
		{
			//throw("There are no realization of finalizer method on DBConnection class");
			trace("Finalize database controller");
		}
	}
}