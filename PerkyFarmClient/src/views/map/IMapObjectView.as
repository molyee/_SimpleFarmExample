package views.map 
{
	import models.Item;
	import models.ItemType;
	
	/**
	 * Интерфейс объектов, располагаемых на карте
	 * ...
	 * @author Alex Sarapulov
	 */
	public interface IMapObjectView
	{
		/**
		 * Количество занимаемых тайлов по ширине
		 * 
		 */
		function get w():int;
		
		/**
		 * Количество занимаемых тайлов по высоте
		 * 
		 */
		function get h():int;
		
		/**
		 * X координата основного тайла привязки
		 * 
		 */
		function get xpos():int;
		
		/**
		 * Y координата основного тайла привязки
		 * 
		 */
		function get ypos():int;
		
		/**
		 *  Триггер доступности действий с объектом
		 * 
		 */
		function get enabled():Boolean;
		
		/**
		 * Установка позиции на сетке тайлов
		 * 
		 * @param	xpos Позиция X в сетке ячеек карты
		 * @param	ypos Позиция Y в сетке ячеек карты
		 */
		function setPosition(xpos:int, ypos:int):void;
		
		/**
		 * Получение данных о типе объекта
		 * 
		 */
		function get itemType():ItemType;
		
		/**
		 * Получение привязанного объекта карты
		 * 
		 */
		function get mapObject():Item;
		
		/**
		 * Получение идентификатора объекта
		 * 
		 */
		function get itemID():String;
		
		/**
		 * Финализатор
		 * 
		 */
		function dispose():void;
	}
	
}