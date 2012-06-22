package net.airserver.endpoints.socket
{
	import net.airserver.endpoints.IClientHandler;
	import net.airserver.endpoints.IEndPoint;
	import net.airserver.endpoints.socket.handlers.SocketClientHandler;
	import net.airserver.endpoints.socket.handlers.SocketClientHandlerFactory;
	import net.airserver.events.EndPointEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	
	public class SocketEndPoint extends EventDispatcher implements IEndPoint
	{
		
		private var port:uint;
		private var socketClientHandlerFactory:SocketClientHandlerFactory;
		private var serverSocket:ServerSocket;
		
		private var socketClientHandlers:Vector.<SocketClientHandler>;
		
		public function SocketEndPoint(port:uint, socketClientHandlerFactory:SocketClientHandlerFactory)
		{
			this.port = port;
			this.socketClientHandlerFactory = socketClientHandlerFactory;
			socketClientHandlers = new Vector.<SocketClientHandler>();
		}
		
		public function open():void
		{
			socketClientHandlers = new Vector.<SocketClientHandler>();
			//bind the server socket
			serverSocket = new ServerSocket();
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, clientConnectHandler, false, 0, true);
			serverSocket.addEventListener(Event.CLOSE, serverSocketCloseHandler, false, 0, true);
			serverSocket.bind(port);
			serverSocket.listen();
			trace("bound socket to port: " + port);
		}
		
		public function close():void
		{
			//close all socket clienthandlers
			for each(var clientHandler:IClientHandler in socketClientHandlers)
			{
				clientHandler.close();
			}
			//reset vector
			socketClientHandlers = new Vector.<SocketClientHandler>();
			//close the socket
			if(serverSocket != null)
			{
				serverSocket.close();
			}
		}
		
		private function clientConnectHandler(event:ServerSocketConnectEvent):void
		{
			//create the clienthandler
			var clientHandler:IClientHandler = socketClientHandlerFactory.createHandler(event.socket);
			//add event listeners to the clienthandler
			clientHandler.addEventListener(Event.CLOSE, clientHandlerCloseHandler, false, 0, true);
			socketClientHandlers.push(clientHandler);
			//dispatch added event
			var e:EndPointEvent = new EndPointEvent(EndPointEvent.CLIENT_HANDLER_ADDED);
			e.clientHandler = clientHandler;
			dispatchEvent(e);
		}
		
		private function serverSocketCloseHandler(event:Event):void
		{
			close();
		}
		
		private function clientHandlerCloseHandler(event:Event):void
		{
			trace("SocketEndPoint: clientHandlerCloseHandler");
			var clientHandler:IClientHandler = event.target as IClientHandler;
			//remove event listener
			clientHandler.removeEventListener(Event.CLOSE, clientHandlerCloseHandler);
			//remove it from the vector
			var index:int = socketClientHandlers.indexOf(clientHandler);
			if(index > -1) socketClientHandlers.splice(index, 1);
		}
	}
}