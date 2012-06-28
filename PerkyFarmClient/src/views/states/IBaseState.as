package views.states 
{
	import flash.events.IEventDispatcher;
	
	/**
	 * Интерфейс состояния визуализации
	 * ...
	 * @author Alex Sarapulov
	 */
	public interface IBaseState extends IEventDispatcher
	{
		/**
		 * Идентификатор состояния (имя)
		 * 
		 */		
		function get stateID():String;
		
		/**
		 * Триггер включения состояния
		 * 
		 */		
		function get selected():Boolean;
		
		/**
		 * Подключить(true)/отключить(false) состояние
		 * 
		 */		
		function setSelection(selected:Boolean):void;
		
		/**
		 * Запуск активности состояния
		 * 
		 */		
		function start():void;
		
		/**
		 * Остановка активности состояния
		 * 
		 */		
		function stop():void;
		
		/**
		 * Обработчик изменения размера внешнего контейнера (или stage),
		 * для обновления позиции и размера вхождения
		 * 
		 * @param width Ширина внешнего контейнера (пиксели)
		 * @param height Высота внешнего контейнера (пиксели)
		 * 
		 */		
		function resize(width:Number, height:Number):void;
	}
	
}