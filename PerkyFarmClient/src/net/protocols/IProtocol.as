package net.protocols 
{
	import flash.events.IEventDispatcher;
	/**
	 * Интерфейс протокола
	 * ...
	 * @author Alex Sarapulov
	 */
	public interface IProtocol extends IEventDispatcher
	{
		/**
		 * Триггер доступности объекта
		 * 
		 */
		function get isOpen():Boolean;
		
		/**
		 * Подключение к объекту
		 * 
		 * @param	host Хост
		 * @param	port Порт
		 * 
		 */
		function connect(host:String = null, port:* = null):void;
		
		/**
		 * Передача данных объекту
		 * 
		 * @param	data Передаваемые данные
		 */
		function send(data:*):void;
		
		/**
		 * Финализатор объекта протокола (закрытие протокола)
		 * 
		 */ 
		function dispose():void;
	}
	
}