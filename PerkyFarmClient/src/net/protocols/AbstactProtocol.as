package net.protocols 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import net.serialize.ISerializer;
	
	
	/**
	 * Класс протокола передачи данных.
	 * Использовать в качестве базового класса для протокола
	 * ...
	 * @author Alex Sarapulov
	 */
	public class AbstactProtocol extends EventDispatcher implements IProtocol
	{
		/**
		 * Обработчик получения сериализованных данных
		 * @private
		 */
		protected var _receiveHandler:Function;
		
		/**
		 * Сериализатор данных
		 * @private
		 */
		protected var _serializer:ISerializer;
		
		/**
		 * Триггер доступности удаленного объекта
		 * @private
		 */
		public function get isOpen():Boolean {
			throw('AbstractProtocol class property "get isOpen" must be overriden');
			return false;
		}
		
		/**
		 * Конструктор класса
		 * 
		 * @param	serializer Сериализатор передаваемых данных
		 * @param	receiveHandler Обработчик получения сериализованных данных
		 * 
		 */
		public function AbstactProtocol(serializer:ISerializer, receiveHandler:Function) 
		{
			_serializer = serializer;
			_receiveHandler = receiveHandler;
		}
		
		/**
		 * Создание подключения
		 * 
		 * @param	host Хост соединения
		 * @param	port Порт соединения
		 * @private
		 */
		public function connect(host:String = null, port:* = null):void
		{
			throw('AbstractProtocol class method "connect(host:String, port:uint)" must be overriden');
		}
		
		/**
		 * Отправка данных
		 * 
		 * @param	data Передаваемые данные
		 */
		public function send(data:*):void
		{
			throw('AbstractProtocol class method "send(data:*)" must be overriden');
		}
		
		/**
		 * Деструктор объекта протокола
		 * 
		 */
		public function dispose():void
		{
			_receiveHandler = null;
		}
	}

}