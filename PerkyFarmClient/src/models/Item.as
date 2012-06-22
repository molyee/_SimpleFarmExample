package models
{
	import models.items.ItemSize;
	import models.items.ItemType;
	import models.VObject;
	import models.Model;
	import models.User;

	/**
	 * элемент карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class Item extends VObject
	{
		// уникальный идентификатор объекта карты
		public var id:String;
		
		// тип шаблона объекта
		public var item_type:String;
		
		// идентификатор владельца объекта (пользователя)
		public var owner_id:String;
		
		// горизонтальная позиция
		public var x:int;
		
		// вертикальная позиция
		public var y:int;
		
		// текущий уровень развития объекта
		public var level:uint = 0;
		
		// максимально допустимый уровень для объекта
		public function get maxLevel():uint {
			return ItemType.maxLevel(item_type);
		}
		
		// шаблонный размер объекта
		public function get size():ItemSize {
			return ItemType.getSize(item_type);
		}
		
		// -- конструктор
		public function Item(source:Object = null)
		{
			super(source);
		}
		
		// переход объекта на следующий уровень
		public function upgrade():Boolean
		{
			if (level >= maxLevel)
				return false; // максимальный уровень уже был достигнут
			level++;
			return true;
		}
		
		// установка позиции объекта
		public function setPosition(xpos:int, ypos:int):void
		{
			x = xpos;
			y = ypos;
		}
		
		// установка владельца объекта
		public function setOwner(ownerID:String):void
		{
			owner_id = ownerID;
		}
		
		// ликвидация объекта карты
		public function dispose():void
		{
			
		}
	}
}