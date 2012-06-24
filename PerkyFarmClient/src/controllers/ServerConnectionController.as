package controllers 
{
	import data.DBConnection;
	import data.ServerResourceStorage;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.Socket;
	import flash.utils.Dictionary;
	
	import logging.Logger;
	
	import net.connection.Client;

	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ServerConnectionController extends ConnectionController
	{
		protected var _clients:Dictionary;
		public function get clients():Dictionary { return _clients; }
		
		protected var _db:DBConnection;
		
		protected var _enabled:Boolean;
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			_enabled = value;
			Logger.instance.writeLine("Server controller enabled=" + _enabled);
		}
		
		protected var _storage:ServerResourceStorage;
		
		public function ServerConnectionController(databaseConnection:DBConnection, storage:ServerResourceStorage) 
		{
			super();
			_db = databaseConnection;
			_clients = new Dictionary(true);
			_storage = storage;
			
			if (_db.connected) initHandler();
			else _db.addEventListener(Event.COMPLETE, initHandler);
			
			Logger.instance.writeLine("Server controller created");
		}
		
		public function initHandler(event:Event = null):void
		{
			if (event) {
				event.stopImmediatePropagation();
				(event.currentTarget as IEventDispatcher).removeEventListener(Event.COMPLETE, initHandler);
			}
			_inited = true;
			dispatchEvent(new Event(Event.INIT));
		}
		
		
		// получение данных ресурса
		override public function getResource(url:String, callback:Function):void
		{
			callback(_storage.getResource(url));
		}
		
		// получение данных о пользователе
		override public function getUserData(userID:String, callback:Function):void
		{
			throw("Abstract method getUserData(userID:String, callback:Function) must be overriden");
		}
		
		// получение данных о типе объекта на карте
		override public function getItemTypeData(itemType:String, callback:Function):void
		{
			throw("Abstract method getItemTypeData(itemType:String, callback:Function) must be overriden");
		}
		
		// ------ user api
		
		// установка нового объекта в заданное место на карте пользователя
		override public function placeItem(client:Client, itemType:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			return true;
		}
		
		// перемещение объекта в заданное место на карте пользователя
		override public function moveItem(client:Client, itemID:String, xpos:int, ypos:int, callback:Function):Boolean
		{
			return true;
		}
		
		// сбор готового объекта
		override public function collectItem(client:Client, itemID:String, callback:Function):Boolean
		{
			return true;
		}
		
		// инкремент уровня всех объектов на карте пользователя
		override public function upgradeItems(client:Client, itemIDs:Array, callback:Function):Array
		{
			return itemIDs;
		}
		
		
		public function getClient(socket:Socket):Client
		{
			return _clients[socket];
		}
		
		public function addClient(socket:Socket):void
		{
			if (!_enabled) {
				socket.close();
				Logger.instance.writeLine("Socket closed " + socket.remoteAddress + ":" + socket.remotePort);
			}
			var client:Client = new Client(this, socket);
			_clients[socket] = client;
			socket.addEventListener(Event.CLOSE, closeClientConnectionHandler);
			Logger.instance.writeLine("Add new client " + socket.remoteAddress + ":" + socket.remotePort);
		}
		
		protected function closeClientConnectionHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			var socket:Socket = event.currentTarget as Socket;
			removeClient(socket);
		}
		
		public function removeClient(socket:Socket):void
		{
			socket.removeEventListener(Event.CLOSE, closeClientConnectionHandler);
			var client:Client = getClient(socket);
			client.dispose();
			delete _clients[socket];
			Logger.instance.writeLine("Remove client " + socket.remoteAddress + ":" + socket.remotePort);
		}
		
		override public function call(client:Client, method:String, data:*, callback:Function):void
		{
			var result:*;
			switch (method) {
				case "placeItem":
					result = placeItem(client, data['item_type'], data['x'], data['y'], null);
				case "moveItem":
					result = moveItem(client, data['id'], data['x'], data['y'], null);
				case "collectItem":
					result = collectItem(client, data, null);
				case "upgradeItems":
					result = upgradeItems(client, data, null);
				default:
					result = data;
			}
			callback(result);
		}
	}

}