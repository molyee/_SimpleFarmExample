package models
{
	import flash.events.Event;
	import models.ItemType;
	import models.VObject;
	import models.Model;
	import models.User;

	/**
	 * Класс объекта (элемента) карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class Item extends VObject
	{
		/**
		 * Уникальный идентификатор объекта карты
		 * 
		 */
		public var id:String;
		
		/**
		 * Тип шаблона объекта
		 * 
		 */
		public var item_type:String;
		
		/**
		 * Идентификатор владельца объекта (пользователя)
		 * 
		 */
		public var owner_id:String;
		
		/**
		 * Горизонтальная позиция
		 * 
		 */
		public var x:int;
		
		/**
		 * Вертикальная позиция
		 * 
		 */
		public var y:int;
		
		/**
		 * Текущий уровень развития объекта
		 * 
		 */
		public var level:uint = 0;
		
		/**
		 * Размер объекта
		 * 
		 */
		public function get size():Array {
			return ItemType.getItemTypeData(item_type).size;
		}
		
		/**
		 * Максимальный уровень объекта
		 * 
		 */
		public function get maxLevel():uint {
			return ItemType.getItemTypeData(item_type).maxLevel;
		}
		
		/**
		 * Триггер доступности действий
		 * 
		 */
		public var enabled:Boolean = true;
		
		/**
		 * Конструктор
		 * 
		 * @param	source Данные полей объекта
		 */
		public function Item(source:Object = null)
		{
			super(source);
		}
		
		/**
		 * Переход объекта на следующий уровень
		 * 
		 * @return Результат действия, если (true), то действие завершено с успехом
		 */
		public function upgrade():Boolean
		{
			if (level >= maxLevel)
				return false; // максимальный уровень уже был достигнут
			level++;
			if (id) dispatchEvent(new Event(Event.CHANGE));
			return true;
		}
		
		/**
		 * Установка позиции объекта
		 * 
		 * @param	xpos Позиция X ячейки на карте пользователя
		 * @param	ypos Позиция Y ячейки на карте пользователя
		 * @see Isometric
		 */
		public function setPosition(xpos:int, ypos:int):void
		{
			x = xpos;
			y = ypos;
			if (id) dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Установка владельца объекта
		 * 
		 * @param	ownerID Идентификатор пользователя-владельца объекта
		 */
		public function setOwner(ownerID:String):void
		{
			owner_id = ownerID;
			if (id) dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Ликвидация объекта карты
		 * 
		 */
		public function dispose():void
		{
			throw("Disposer realization not completed yet");
		}
	}
}