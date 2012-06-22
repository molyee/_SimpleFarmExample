package net.airserver.messages.serialization
{
	import net.airserver.messages.Message;

	public interface IMessageSerializer
	{
		function serialize(message:Message):*;
		function deserialize(serialized:*):Message;
	}
}