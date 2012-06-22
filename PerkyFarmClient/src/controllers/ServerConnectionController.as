package controllers 
{
	import data.DBConnection;
	
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
		
		public function ServerConnectionController(databaseConnection:DBConnection) 
		{
			super();
			_db = databaseConnection;
			_clients = new Dictionary(true);
			
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
		
		override public function call(client:Client, method:String, data:Object, callback:Function):void
		{
			callback(data);
		}
		
	}

}