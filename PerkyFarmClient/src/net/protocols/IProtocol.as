package net.protocols 
{
	import flash.events.IEventDispatcher;
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public interface IProtocol extends IEventDispatcher
	{
		// триггер доступности объекта
		function get isOpen():Boolean;
		
		// подключение к объекту
		function connect(host:String = null, port:* = null):void;
		
		// передача данных объекту
		function send(data:*):void;
		
		// финализатор объекта протокола (закрытие протокола)
		function dispose():void;
	}
	
}