package net.airserver.messages.serialization
{
	import net.airserver.messages.Message;
	
	public class NativeObjectSerializer implements IMessageSerializer
	{
		public function NativeObjectSerializer()
		{
		}
		
		public function serialize(message:Message):*
		{
			return message;
		}
		
		public function deserialize(serialized:*):Message
		{
			if(serialized is Message) return serialized;
			var message:Message = new Message();
			if(serialized.hasOwnProperty("senderId")) message.senderId = serialized.senderId;
			if(serialized.hasOwnProperty("command")) message.command = serialized.command;
			if(serialized.hasOwnProperty("data")) message.data = serialized.data;
			else message.data = serialized;
			return message;
		}
	}
}