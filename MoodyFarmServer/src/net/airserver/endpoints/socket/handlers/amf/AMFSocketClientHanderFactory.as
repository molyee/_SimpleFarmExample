package net.airserver.endpoints.socket.handlers.amf
{
	import net.airserver.endpoints.socket.handlers.SocketClientHandler;
	import net.airserver.endpoints.socket.handlers.SocketClientHandlerFactory;
	import net.airserver.messages.serialization.IMessageSerializer;
	
	import flash.net.Socket;
	
	public class AMFSocketClientHanderFactory extends SocketClientHandlerFactory
	{
		public function AMFSocketClientHanderFactory(messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			super(messageSerializer, crossDomainPolicyXML);
		}
		
		override public function createHandler(socket:Socket):SocketClientHandler
		{
			return new AMFSocketClientHandler(socket, messageSerializer, crossDomainPolicyXML);
		}
	}
}