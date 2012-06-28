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
	 * Класс клиента соединения
	 * 
	 * ...
	 * @author Alex Sarapulov
	 */
	public class Client
	{
		protected var _connection:DataConnection;
		/**
		 * Соединение у удаленным объектом
		 * 
		 */
		public function get connection():DataConnection { return _connection; }
		
		/**
		 * Ссылка на контроллер, у которого клиент может вызывать выполнение функций
		 * @private
		 */
		protected var _controller:IConnectionController;
		
		protected var _currentUser:User;
		/**
		 * Объект пользователя, соответствующего клиентскому соединению
		 * 
		 */
		public function get currentUser():User { return _currentUser; }
		/**
		 * Установщик ссылки на объект пользователя
		 * @private
		 */
		public function set currentUser(value:User):void { _currentUser = value; }
		
		/**
		 * Конструктор клиента
		 * 
		 * @param	controller Ссылка на контроллер приложения
		 * @param	socket Сокет соединения
		 * @param	forceReconnection Триггер включения переподключения к удаленному хосту, true - клиент переподключается при разрыве соединения
		 * 
		 */
		public function Client(controller:IConnectionController, user:User, socket:Socket = null, forceReconnection:Boolean = false) 
		{
			_controller = controller;
			_currentUser = user;
			var serializer:* = new XMLSerializer();
			var connectionID:String = Math.round(Math.random() * 1000000000).toString()
			_connection = new DataConnection(connectionID, _controller.call, this, CompressedUTFDataProtocol, serializer, socket, forceReconnection);
		}
		
		/**
		 * Финализатор объекта
		 * 
		 */
		public function dispose():void
		{
			_connection.close();
			_connection = null;
			_currentUser = null;
			_controller = null;
		}
	}

}