package net.airserver
{
	import net.airserver.endpoints.IEndPoint;
	import net.airserver.events.AIRServerEvent;
	import net.airserver.events.EndPointEvent;
	import net.airserver.events.MessageReceivedEvent;
	import net.airserver.messages.Message;
	import net.airserver.util.IDGenerator;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AIRServer extends EventDispatcher
	{
		
		private var started:Boolean;
		
		private var endPoints:Vector.<IEndPoint>;
		private var _clients:Vector.<Client>;
		
		public function get clients():Vector.<Client>
		{
			return _clients.concat();
		}
		
		private var clientsMap:Object;
		
		public function AIRServer()
		{
			_clients = new Vector.<Client>();
			endPoints = new Vector.<IEndPoint>();
			clientsMap = {};
		}
		
		public function addEndPoint(endPointToAdd:IEndPoint):void
		{
			if(endPoints.indexOf(endPointToAdd) == -1)
			{
				endPoints.push(endPointToAdd);
			}
		}
		
		public function start():void
		{
			//open all endpoints
			for each(var endPoint:IEndPoint in endPoints)
			{
				//add event listeners to the endpoint
				endPoint.addEventListener(EndPointEvent.CLIENT_HANDLER_ADDED, clientHandlerAddedHandler, false, 0, true);
				//open it
				endPoint.open();
			}
			started = true;
		}
		
		public function stop():void
		{
			//close all endpoints
			for each(var endPoint:IEndPoint in endPoints)
			{
				//close the endpoint
				endPoint.close();
				//remove event listeners from the endpoint
				endPoint.removeEventListener(EndPointEvent.CLIENT_HANDLER_ADDED, clientHandlerAddedHandler);
			}
			started = false;
		}
		
		public function sendMessageToAllClients(message:Message):void
		{
			for each(var client:Client in _clients)
			{
				client.sendMessage(message);
			}
		}
		
		private function clientHandlerAddedHandler(event:EndPointEvent):void
		{
			trace("AIRSERVER: Client Handler Added Handler");
			var client:Client = new Client(IDGenerator.getUniqueId(), event.clientHandler);
			_clients.push(client);
			clientsMap[client.id] = client;
			//add events to client
			client.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler, false, 0, true);
			client.addEventListener(Event.CLOSE, clientCloseHandler, false, 0, true);
			//dispatch added event
			var e:AIRServerEvent = new AIRServerEvent(AIRServerEvent.CLIENT_ADDED);
			e.client = client;
			dispatchEvent(e);
		}
		
		private function clientCloseHandler(event:Event):void
		{
			trace("AIRSERVER: Client Close Handler");
			var client:Client = event.target as Client;
			var index:int = _clients.indexOf(client);
			if(index > -1) _clients.splice(index, 1);
			delete clientsMap[client.id];
			//remove event listeners
			client.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler);
			client.removeEventListener(Event.CLOSE, clientCloseHandler);
			//dispatch removed event
			var e:AIRServerEvent = new AIRServerEvent(AIRServerEvent.CLIENT_REMOVED);
			e.client = client;
			dispatchEvent(e);
		}
		
		public function getClientById(clientId:uint):Client
		{
			return clientsMap[clientId];
		}
		
		private function messageReceivedHandler(event:MessageReceivedEvent):void
		{
			dispatchEvent(event.clone());
		}
	}
}