package net.airserver
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.Socket;
	
	import models.User;
	
	import net.airserver.endpoints.IClientHandler;
	import net.airserver.events.MessageReceivedEvent;
	import net.airserver.events.MessagesAvailableEvent;
	import net.airserver.messages.Message;
	
	public class Client extends EventDispatcher
	{
		
		private var _id:uint;
		public function get id():uint { return _id; }
		
		private var closed:Boolean;		
		private var clientHandler:IClientHandler;
		
		public function get ipv4():String {
			if (closed)
				return "no connection";
			return clientHandler['ipv4'];
		}
		
		public var user:User;
		
		public function Client(id:uint, clientHandler:IClientHandler)
		{
			this._id = id;
			this.clientHandler = clientHandler;
			
			clientHandler.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
			clientHandler.addEventListener(MessagesAvailableEvent.MESSAGES_AVAILABLE, messagesAvailableHandler, false, 0, true);
		}
		
		private function messagesAvailableHandler(event:MessagesAvailableEvent):void
		{
			while(clientHandler.messagesAvailable)
			{
				var message:Message = clientHandler.readMessage();
				if(message != null)
				{
					message.senderId = this.id;
					dispatchEvent(new MessageReceivedEvent(MessageReceivedEvent.MESSAGE_RECEIVED, message));
				}
			}
		}
		
		public function sendMessage(message:Message):void
		{
			clientHandler.writeMessage(message);
		}
		
		public function close():void
		{
			if (closed) return;
			
			closed = true;
				
			clientHandler.removeEventListener(Event.CLOSE, closeHandler);
			clientHandler.removeEventListener(MessagesAvailableEvent.MESSAGES_AVAILABLE, messagesAvailableHandler);
			clientHandler.close();
			
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function closeHandler(event:Event):void
		{
			close();
		}
		
		override public function toString():String
		{
			return "[Client, " + clientHandler + "]";
		}
	}
}