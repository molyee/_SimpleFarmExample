package net.airserver.endpoints.socket.handlers.websocket
{
	import net.airserver.endpoints.socket.handlers.SocketClientHandler;
	import net.airserver.messages.Message;
	import net.airserver.messages.serialization.IMessageSerializer;
	
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class WebSocketClientHandler extends SocketClientHandler
	{
		public function WebSocketClientHandler(socket:Socket, messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			super(socket, messageSerializer, crossDomainPolicyXML);
		}
		
		override public function readMessage():Message
		{
			var message:Message = null;
			
			if(socketBytes.bytesAvailable > 0)
			{
				var inputString:String = "";
				while(socketBytes.bytesAvailable > 0)
				{
					var byte:int = socketBytes.readByte();
					switch(byte)
					{
						case 0:
						case -1:
							break;
						default:
							inputString += String.fromCharCode(byte);
							break;
					}
				}
				message = messageSerializer.deserialize(inputString);
				socketBytes.clear();
			}
			
			_messagesAvailable = false;
			return message;
		}
		
		override public function writeMessage(messageToWrite:Message):void
		{
			var serialized:String = messageSerializer.serialize(messageToWrite);
			var bytes:ByteArray = new ByteArray();
			bytes.writeByte(0);
			bytes.writeUTFBytes(serialized);
			bytes.writeByte(255);
			writeSocketBytes(bytes);
		}
	}
}