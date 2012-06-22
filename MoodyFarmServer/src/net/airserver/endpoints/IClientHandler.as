package net.airserver.endpoints
{
	import net.airserver.messages.Message;
	
	import flash.events.IEventDispatcher;

	public interface IClientHandler extends IEventDispatcher
	{
		function close():void;
		function get messagesAvailable():Boolean;
		function readMessage():Message;
		function writeMessage(messageToWrite:Message):void;
	}
}