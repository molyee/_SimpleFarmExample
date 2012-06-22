package net.airserver.endpoints.socket.handlers
{
	import by.blooddy.crypto.MD5;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import net.airserver.endpoints.IClientHandler;
	import net.airserver.events.MessagesAvailableEvent;
	import net.airserver.messages.Message;
	import net.airserver.messages.serialization.IMessageSerializer;
	
	public class SocketClientHandler extends EventDispatcher implements IClientHandler
	{
		
		protected var _messagesAvailable:Boolean;
		
		public function get messagesAvailable():Boolean
		{
			return _messagesAvailable;
		}
		
		protected var socketBytes:ByteArray;
		
		private var closed:Boolean;
		private var firstRequestProcessed:Boolean;
		private var socket:Socket;
		
		public function get ipv4():String {
			return socket.remoteAddress + ":" + socket.remotePort;
		}
		
		protected var messageSerializer:IMessageSerializer;
		protected var crossDomainPolicyXML:XML;
		
		public function SocketClientHandler(socket:Socket, messageSerializer:IMessageSerializer, crossDomainPolicyXML:XML = null)
		{
			this.socket = socket;
			this.messageSerializer = messageSerializer;
			this.crossDomainPolicyXML = crossDomainPolicyXML;
			
			if(crossDomainPolicyXML == null)
			{
				crossDomainPolicyXML = new XML("<?xml version=\"1.0\"?>" +
					"<!DOCTYPE cross-domain-policy SYSTEM \"/xml/dtds/cross-domain-policy.dtd\">" +
					"<cross-domain-policy>" +
					"   <allow-access-from domain=\"*\" to-ports=\"*\" />" +
					"</cross-domain-policy>");
			}
			this.crossDomainPolicyXML = crossDomainPolicyXML;
			
			socketBytes = new ByteArray();
			
			socket.addEventListener(Event.CLOSE, socketCloseHandler, false, 0, true);
			socket.addEventListener(IOErrorEvent.IO_ERROR, socketIOErrorHandler, false, 0, true);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler, false, 0, true);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
		}
		
		public function close():void
		{
			if(!closed)
			{
				closed = true;
				if(socket.connected)
				{
					trace("SocketClientHandler: close socket");
					socket.close();
				}
				//dispatch close event
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		public function readMessage():Message
		{
			//override this method in the inheriting classes
			return null;
		}
		
		public function writeMessage(messageToWrite:Message):void
		{
			//override this method in the inheriting classes
		}
		
		private function socketCloseHandler(event:Event):void
		{
			close();
		}
		
		private function socketIOErrorHandler(event:IOErrorEvent):void
		{
		}
		
		private function socketDataHandler(event:ProgressEvent):void
		{
			if(socket.bytesAvailable > 0)
			{
				//this might be a policy file request, so check this here
				if(!firstRequestProcessed)
				{
					firstRequestProcessed = true;
					//process each byte, and send a cross domain reply, before the NULL byte
					while(socket.bytesAvailable > 0)
					{
						var byte:int = socket.readByte();
						socketBytes.writeByte(byte);
						if(byte == 62)
						{
							//policy file request?
							socketBytes.position = 0;
							var msg:String = socketBytes.readUTFBytes(socketBytes.length);
							try
							{
								var msgXML:XML = new XML(msg);
								if(msgXML.name() == "policy-file-request")
								{
									//send a crossdomain reply
									var crossDomainReply:ByteArray = new ByteArray();
									crossDomainReply.writeUTFBytes(crossDomainPolicyXML.toXMLString());
									crossDomainReply.writeByte(0);
									socket.writeBytes(crossDomainReply);
									socket.flush();
									//stop right here
									socketBytes.clear();
									return;
								}
							}
							catch(e:Error)
							{
							}
						}
					}
					//websockets handshake?
					socketBytes.position = 0;
					var message:String = socketBytes.readUTFBytes(socketBytes.bytesAvailable);
					if(message.indexOf("GET ") == 0)
					{
						var messageLines:Array = message.split("\n");
						var fields:Object = {};
						var requestedURL:String = "";
						for(var i:uint = 0; i < messageLines.length; i++)
						{
							var line:String = messageLines[i];
							if(i == 0)
							{
								var getSplit:Array = line.split(" ");
								if(getSplit.length > 1)
								{
									requestedURL = getSplit[1];
								}
							}
							else
							{
								var index:int = line.indexOf(":");
								if(index > -1)
								{
									var key:String = line.substr(0, index);
									fields[key] = line.substr(index + 1).replace( /^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2" );
								}
							}
						}
						//check the websocket version
						if(fields["Sec-WebSocket-Version"] != null)
						{
							//NOT SUPPORTED YET
						}
						else
						{
							if(fields["Sec-WebSocket-Key1"] != null && fields["Sec-WebSocket-Key2"] != null)
							{
								//draft-ietf-hybi-thewebsocketprotocol-00
								//send a response
								var result:* = fields["Sec-WebSocket-Key1"].match(/[0-9]/gi);
								var key1Nr:uint = (result is Array) ? uint(result.join("")) : 1;
								result = fields["Sec-WebSocket-Key1"].match(/ /gi);
								var key1SpaceCount:uint = (result is Array) ? result.length : 1;
								var key1Part:Number = key1Nr / key1SpaceCount;

								result = fields["Sec-WebSocket-Key2"].match(/[0-9]/gi);
								var key2Nr:uint = (result is Array) ? uint(result.join("")) : 1;
								result = fields["Sec-WebSocket-Key2"].match(/ /gi);
								var key2SpaceCount:uint = (result is Array) ? result.length : 1;
								var key2Part:Number = key2Nr / key2SpaceCount;

								//calculate binary md5 hash
								var bytesToHash:ByteArray = new ByteArray();
								bytesToHash.writeUnsignedInt(key1Part);
								bytesToHash.writeUnsignedInt(key2Part);
								bytesToHash.writeBytes(socketBytes, socketBytes.length - 8);
								
								//hash it
								var hash:String = MD5.hashBytes(bytesToHash);
								
								var response:String = "HTTP/1.1 101 WebSocket Protocol Handshake\r\n" +
									"Upgrade: WebSocket\r\n" +
									"Connection: Upgrade\r\n" +
									"Sec-WebSocket-Origin: " + fields["Origin"] + "\r\n" +
									"Sec-WebSocket-Location: ws://" + fields["Host"] + requestedURL + "\r\n" +
									"\r\n";
								var responseBytes:ByteArray = new ByteArray();
								responseBytes.writeUTFBytes(response);

								for(i = 0; i < hash.length; i += 2)
								{
									responseBytes.writeByte(parseInt(hash.substr(i, 2), 16));
								}
								
								responseBytes.writeByte(0);
								responseBytes.position = 0;
								socket.writeBytes(responseBytes);
								socket.flush();
								//stop right here
								socketBytes.clear();
								return;
							}
						}
					}
				}
				else
				{
					socket.readBytes(socketBytes, socketBytes.position);
				}
				socketBytes.position = 0;
				_messagesAvailable = true;
				dispatchEvent(new MessagesAvailableEvent(MessagesAvailableEvent.MESSAGES_AVAILABLE));
			}
		}
		
		protected function writeSocketBytes(bytes:ByteArray):void
		{
			socket.writeBytes(bytes);
			socket.flush();
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
		}
		
		override public function toString():String
		{
			return "[SocketClientHandler local=" + socket.localAddress + ":" + socket.localPort + ", remote=" + socket.remoteAddress + ":" + socket.remotePort;
		}
	}
}