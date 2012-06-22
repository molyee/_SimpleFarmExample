package net.protocols 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import net.serialize.ISerializer;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class AbstactProtocol extends EventDispatcher implements IProtocol
	{
		protected var _receiveHandler:Function; // обработчик получения сериализованных данных
		protected var _serializer:ISerializer; // сериализатор данных
		
		// триггер доступности удаленного объекта
		public function get isOpen():Boolean {
			throw('AbstractProtocol class property "get isOpen" must be overriden');
			return false;
		}
		
		// -- конструктор
		public function AbstactProtocol(serializer:ISerializer, receiveHandler:Function) 
		{
			_serializer = serializer;
			_receiveHandler = receiveHandler;
		}
		
		// создание подключения
		public function connect(host:String = null, port:* = null):void
		{
			throw('AbstractProtocol class method "connect(host:String, port:uint)" must be overriden');
		}
		
		// отправка данных
		public function send(data:*):void
		{
			throw('AbstractProtocol class method "send(data:*)" must be overriden');
		}
		
		// -- финализатор
		public function dispose():void
		{
			_receiveHandler = null;
		}
	}

}