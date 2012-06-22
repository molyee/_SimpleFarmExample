package net.airserver.endpoints.socket.handlers.amf
{
	import net.airserver.endpoints.socket.handlers.SocketClientHandler;
	import net.airserver.messages.Message;
	import net.airserver.messages.serialization.IMessageSerializer;
	
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class AMFSocketClientHandler extends SocketClientHandler
	{
		
		public function AMFSocketClientHandler(socket:Socket, messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			super(socket, messageSerializer, crossDomainPolicyXML);
		}
		
		override public function readMessage():Message
		{
			var message:Message = null;
			
			if(socketBytes.bytesAvailable > 0)
			{
				try
				{
					var o:Object = socketBytes.readObject();
					message = messageSerializer.deserialize(o);
					//set the socket bytes to the remaining bytes in the bytearray
					var newBytes:ByteArray = new ByteArray();
					newBytes.writeBytes(socketBytes, socketBytes.position);
					socketBytes = newBytes;
				}
				catch(error:RangeError)
				{
					//something went wrong
					trace(error.message);
					socketBytes.clear();
				}
			}
			
			_messagesAvailable = (socketBytes.position < socketBytes.length);
			return message;
		}
		
		override public function writeMessage(messageToWrite:Message):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(messageSerializer.serialize(messageToWrite));
			writeSocketBytes(bytes);
		}
	}
}