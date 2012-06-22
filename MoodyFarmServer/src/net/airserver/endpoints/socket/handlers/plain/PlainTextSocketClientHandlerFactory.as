package net.airserver.endpoints.socket.handlers.plain
{
	import net.airserver.endpoints.socket.handlers.SocketClientHandler;
	import net.airserver.endpoints.socket.handlers.SocketClientHandlerFactory;
	import net.airserver.messages.serialization.IMessageSerializer;
	
	import flash.net.Socket;
	
	public class PlainTextSocketClientHandlerFactory extends SocketClientHandlerFactory
	{
		public function PlainTextSocketClientHandlerFactory(messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			super(messageSerializer, crossDomainPolicyXML);
		}
		
		override public function createHandler(socket:Socket):SocketClientHandler
		{
			return new PlainTextSocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
		}
	}
}