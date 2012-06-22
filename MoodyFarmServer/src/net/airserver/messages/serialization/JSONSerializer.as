package net.airserver.messages.serialization
{
	import by.blooddy.crypto.serialization.JSON;
	
	import net.airserver.messages.Message;
	
	public class JSONSerializer implements IMessageSerializer
	{

		public function JSONSerializer()
		{
		}
		
		public function serialize(message:Message):*
		{
			return by.blooddy.crypto.serialization.JSON.encode(message);
		}
		
		public function deserialize(serialized:*):Message
		{
			var decoded:Object = by.blooddy.crypto.serialization.JSON.decode(serialized);
			var message:Message = new Message();
			if(decoded.hasOwnProperty("senderId")) message.senderId = decoded.senderId;
			if(decoded.hasOwnProperty("command")) message.command = decoded.command;
			if(decoded.hasOwnProperty("data")) message.data = decoded.data;
			else message.data = decoded;
			return message;
		}
	}
}