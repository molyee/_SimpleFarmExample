package net.airserver.endpoints.socket.handlers.plain
{
	import net.airserver.endpoints.socket.handlers.SocketClientHandler;
	import net.airserver.messages.Message;
	import net.airserver.messages.serialization.IMessageSerializer;
	
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class PlainTextSocketClientHandler extends SocketClientHandler
	{
		public function PlainTextSocketClientHandler(socket:Socket, messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			super(socket, messageSerializer, crossDomainPolicyXML);
		}
		
		override public function readMessage():Message
		{
			var message:Message = null;
			
			if(socketBytes.bytesAvailable > 0)
			{
				message = messageSerializer.deserialize(socketBytes.readUTFBytes(socketBytes.length));
				socketBytes.clear();
			}

			_messagesAvailable = false;
			return message;
		}
		
		override public function writeMessage(messageToWrite:Message):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(messageSerializer.serialize(messageToWrite));
			writeSocketBytes(bytes);
		}
	}
}