package views.states 
{
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author alex
	 */
	public interface IBaseState extends IEventDispatcher
	{
		// идентификатор состояния (имя)
		function get stateID():String;
		
		// триггер включения состояния
		function get selected():Boolean;
		
		// подключить(true)/отключить(false) состояние
		function setSelection(selected:Boolean):void;
		
		// запуск активности состояния
		function start():void;
		
		// остановка активности состояния
		function stop():void;
		
		// обработчик изменения внешнего контейнера (или stage), для обновления позиции и размера вхождения
		function resize(width:Number, height:Number):void;
	}
	
}