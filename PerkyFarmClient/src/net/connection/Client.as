package net.connection 
{
	import controllers.IConnectionController;
	
	import flash.events.Event;
	import flash.net.Socket;
	
	import models.User;
	
	import net.connection.DataConnection;
	import net.protocols.CompressedUTFDataProtocol;
	import net.serialize.ISerializer;
	import net.serialize.XMLSerializer;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class Client
	{
		// соединение у удаленным объектом
		protected var _connection:DataConnection;
		public function get connection():DataConnection { return _connection; }
		
		// объект, у которого вызываются функции
		protected var _controller:IConnectionController;
		
		// объект пользователя соответствующего клиентскому соединению
		protected var _currentUser:User;
		public function get currentUser():User { return _currentUser; }
		
		// -- конструктор
		public function Client(controller:IConnectionController, socket:Socket = null, forceReconnection:Boolean = false) 
		{
			_controller = controller;
			_currentUser = new User();
			var serializer:* = new XMLSerializer();
			var connectionID:String = Math.round(Math.random() * 1000000000).toString()
			_connection = new DataConnection(connectionID, _controller.call, this, CompressedUTFDataProtocol, serializer, socket, forceReconnection);
		}
		
		// -- финализатор
		public function dispose():void
		{
			_connection.close();
			_connection = null;
			_currentUser = null;
			_controller = null;
		}
	}

}