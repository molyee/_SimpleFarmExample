package views.map 
{
	import models.Item;
	import models.ItemType;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public interface IMapObjectView
	{
		// количество занимаемых тайлов по ширине
		function get w():int;
		
		// количество занимаемых тайлов по высоте
		function get h():int;
		
		// x координата основного тайла привязки
		function get xpos():int;
		
		// y координата основного тайла привязки
		function get ypos():int;
		
		// триггер доступности действий
		function get enabled():Boolean;
		
		// установка позиции на сетке тайлов
		function setPosition(xpos:int, ypos:int):void;
		
		// получение данных о типе объекта
		function get itemType():ItemType;
		
		// получение привязанного объекта карты
		function get mapObject():Item;
		
		// получение идентификатора объекта
		function get itemID():String;
		
		// финализатор
		function dispose():void;
	}
	
}