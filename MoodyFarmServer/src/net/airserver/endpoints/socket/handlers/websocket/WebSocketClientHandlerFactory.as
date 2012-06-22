package net.airserver.endpoints.socket.handlers.websocket
{
	import net.airserver.endpoints.socket.handlers.SocketClientHandler;
	import net.airserver.endpoints.socket.handlers.SocketClientHandlerFactory;
	import net.airserver.messages.serialization.IMessageSerializer;
	
	import flash.net.Socket;
	
	public class WebSocketClientHandlerFactory extends SocketClientHandlerFactory
	{
		public function WebSocketClientHandlerFactory(messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			super(messageSerializer, crossDomainPolicyXML);
		}
		
		override public function createHandler(socket:Socket):SocketClientHandler
		{
			return new WebSocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
		}
	}
}