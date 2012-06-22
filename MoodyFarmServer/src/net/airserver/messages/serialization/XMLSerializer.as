package net.airserver.messages.serialization
{
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.rpc.xml.SimpleXMLEncoder;
	
	import net.airserver.messages.Message;
	
	public class XMLSerializer implements IMessageSerializer
	{
		private static const _decoder:SimpleXMLDecoder = new SimpleXMLDecoder();
		private static const _encoder:SimpleXMLEncoder = new SimpleXMLEncoder(new XMLDocument());
		
		public function XMLSerializer()
		{
			
		}
		
		public function serialize(message:Message):*
		{
			return new XML(message.data);
		}
		
		public function deserialize(serialized:*):Message
		{
			var decoded:Object = XML(serialized);
			var message:Message = new Message();
			if(decoded.hasOwnProperty("senderId")) message.senderId = decoded.senderId;
			if(decoded.hasOwnProperty("command")) message.command = decoded.command;
			if(decoded.hasOwnProperty("data")) message.data = decoded.data;
			else message.data = decoded;
			return message;
		}
	}
}