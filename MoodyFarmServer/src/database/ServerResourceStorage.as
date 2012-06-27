package database
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.ServerSocketConnectEvent;
	import flash.geom.Rectangle;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import logging.Logger;
	
	import mx.core.Application;
	import mx.effects.easing.Back;
	import mx.rpc.http.HTTPMultiService;
	
	import net.protocols.BitDataProtocol;
	import net.serialize.UTFBitSerializer;

	public class ServerResourceStorage
	{
		[Embed(source="../../media/grass_texture.jpg")]
		private static const BACKGROUND_TEXTURE:Class;
		
		[Embed(source="../../media/items/potato/1.png")]
		private static const POTATO_1:Class;
		[Embed(source="../../media/items/potato/2.png")]
		private static const POTATO_2:Class;
		[Embed(source="../../media/items/potato/3.png")]
		private static const POTATO_3:Class;
		[Embed(source="../../media/items/potato/4.png")]
		private static const POTATO_4:Class;
		[Embed(source="../../media/items/potato/5.png")]
		private static const POTATO_5:Class;
		
		[Embed(source="../../media/items/clover/1.png")]
		private static const CLOVER_1:Class;
		[Embed(source="../../media/items/clover/2.png")]
		private static const CLOVER_2:Class;
		[Embed(source="../../media/items/clover/3.png")]
		private static const CLOVER_3:Class;
		[Embed(source="../../media/items/clover/4.png")]
		private static const CLOVER_4:Class;
		[Embed(source="../../media/items/clover/5.png")]
		private static const CLOVER_5:Class;
		
		[Embed(source="../../media/items/sunflower/1.png")]
		private static const SUNFLOWER_1:Class;
		[Embed(source="../../media/items/sunflower/2.png")]
		private static const SUNFLOWER_2:Class;
		[Embed(source="../../media/items/sunflower/3.png")]
		private static const SUNFLOWER_3:Class;
		[Embed(source="../../media/items/sunflower/4.png")]
		private static const SUNFLOWER_4:Class;
		[Embed(source="../../media/items/sunflower/5.png")]
		private static const SUNFLOWER_5:Class;
		
		[Embed(source="../../media/items/sunflower/1.png")]
		private static const BIG_SUNFLOWER_1:Class;
		[Embed(source="../../media/items/sunflower/2.png")]
		private static const BIG_SUNFLOWER_2:Class;
		
		
		private var _resources:Object = {};
		private var _xmlResources:Array = ["/config/item_types.xml"];
		
		
		private static const CONFIG_PATH:String = "/config/";
		private static const MEDIA_PATH:String = "/media/";
		private static const ITEM_IMAGES_PATH:String = "/media/items/";
		
		private var _serverSocket:ServerSocket;
		
		private var _connections:Dictionary;
		
		private var _serializer:UTFBitSerializer;
		
		public function ServerResourceStorage(port:int)
		{
			_resources[MEDIA_PATH + "background.jpg"] = new BACKGROUND_TEXTURE();
			
			_resources[ITEM_IMAGES_PATH + "potato/1.png"] = new POTATO_1();
			_resources[ITEM_IMAGES_PATH + "potato/2.png"] = new POTATO_2();
			_resources[ITEM_IMAGES_PATH + "potato/3.png"] = new POTATO_3();
			_resources[ITEM_IMAGES_PATH + "potato/4.png"] = new POTATO_4();
			_resources[ITEM_IMAGES_PATH + "potato/5.png"] = new POTATO_5();
			
			_resources[ITEM_IMAGES_PATH + "clover/1.png"] = new CLOVER_1();
			_resources[ITEM_IMAGES_PATH + "clover/2.png"] = new CLOVER_2();
			_resources[ITEM_IMAGES_PATH + "clover/3.png"] = new CLOVER_3();
			_resources[ITEM_IMAGES_PATH + "clover/4.png"] = new CLOVER_4();
			_resources[ITEM_IMAGES_PATH + "clover/5.png"] = new CLOVER_5();
			
			_resources[ITEM_IMAGES_PATH + "sunflower/1.png"] = new SUNFLOWER_1();
			_resources[ITEM_IMAGES_PATH + "sunflower/2.png"] = new SUNFLOWER_2();
			_resources[ITEM_IMAGES_PATH + "sunflower/3.png"] = new SUNFLOWER_3();
			_resources[ITEM_IMAGES_PATH + "sunflower/4.png"] = new SUNFLOWER_4();
			_resources[ITEM_IMAGES_PATH + "sunflower/5.png"] = new SUNFLOWER_5();
			
			_resources[ITEM_IMAGES_PATH + "big_sunflower/1.png"] = new BIG_SUNFLOWER_1();
			_resources[ITEM_IMAGES_PATH + "big_sunflower/2.png"] = new BIG_SUNFLOWER_2();
			
			
			var itemTypesXML:XML = new XML(
				'<?xml version="1.0" encoding="UTF-8" ?>' +
				'<itemTypes imagesPath="/media/items" imgFormat="png" >' +
					'<itemType name="clover" levels="5" w="1" h="1">' +
						'<images>' +
							'<img id="1" x="0" y="3" />' +
							'<img id="2" x="0" y="24" />' +
							'<img id="3" x="0" y="21" />' +
							'<img id="4" x="0" y="20" />' +
							'<img id="5" x="0" y="17" def="1" />' +
						'</images>' +
					'</itemType>' +
					'<itemType name="potato" levels="5" w="1" h="1">' +
						'<images>' +
							'<img id="1" x="0" y="25" />' +
							'<img id="2" x="0" y="25" />' +
							'<img id="3" x="0" y="17" />' +
							'<img id="4" x="0" y="16" />' +
							'<img id="5" x="0" y="14" def="1" />' +
						'</images>' +
					'</itemType>' +
					'<itemType name="sunflower" levels="5" w="1" h="1">' +
						'<images>' +
							'<img id="1" x="0" y="26" />' +
							'<img id="2" x="0" y="17" />' +
							'<img id="3" x="0" y="10" />' +
							'<img id="4" x="0" y="-2" />' +
							'<img id="5" x="0" y="-10" def="1" />' +
						'</images>' +
					'</itemType>' +
					'<itemType name="big_sunflower" levels="2" w="3" h="3">' +
						'<images>' +
							'<img id="1" x="0" y="26" />' +
							'<img id="2" x="0" y="17" def="1" />' +
						'</images>' +
					'</itemType>' +
				'</itemTypes>');
			
			_resources[CONFIG_PATH + "item_types.xml"] = itemTypesXML;
			
			_connections = new Dictionary();
			
			_serializer = new UTFBitSerializer();
			
			_serverSocket = new ServerSocket();
			_serverSocket.addEventListener(Event.CLOSE, closeHandler);
			_serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, clientConnectHandler);
			_serverSocket.bind(port);
			_serverSocket.listen();
			
			Logger.instance.writeLine("Static server on TCP:" + port + " port");
		}
		
		private function closeHandler(event:Event):void
		{
			Logger.instance.writeLine("Static server closed");
		}
		
		private function clientConnectHandler(event:ServerSocketConnectEvent):void
		{
			Logger.instance.writeLine("Client connected to static storage");
			var socket:Socket = event.socket;
			socket.addEventListener(Event.CLOSE, closeConnectionHandler);
			var bitProtocol:BitDataProtocol = new BitDataProtocol(getRequest, socket);
			_connections[socket] = bitProtocol;
		}
		
		private function closeConnectionHandler(event:Event):void
		{
			var socket:Socket = event.currentTarget as Socket;
			socket.removeEventListener(Event.CLOSE, closeConnectionHandler);
			var bitProtocol:BitDataProtocol = _connections[socket];
			bitProtocol.dispose();
			delete _connections[socket];
		}
		private function getRequest(protocol:BitDataProtocol, data:ByteArray):void
		{
			var byteArray:ByteArray = new ByteArray();
			var url:String = _serializer.decode(data);
			var resource:* = getResource(url);
			var resourceType:String = url.substring(url.length - 4, url.length);
			if (resourceType == ".xml") {
				byteArray.writeUTFBytes((resource as XML).toString());
			} else {
				var image:Bitmap = resource as Bitmap;
				var rect:Rectangle = new Rectangle(0, 0, image.width, image.height);
				byteArray.writeInt(int(image.width));
				byteArray.writeInt(int(image.height));
				byteArray.writeBytes(image.bitmapData.getPixels(rect));
			}
			byteArray.position = 0;
			protocol.send(byteArray);
		}
		
		public function getResource(path:String):*
		{
			return _resources[path];
		}
	}
}