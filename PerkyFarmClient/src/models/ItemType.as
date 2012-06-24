package models
{
	/**
	 * класс типов элементов карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ItemType
	{
		
		protected static const ITEM_TYPES:Object = { };
		
		public static function getItemTypeData(itemType:String):ItemType
		{
			return ITEM_TYPES[itemType];
		}
		
		public static function initItemTypes(itemTypesData:XML):void
		{
			trace(itemTypesData);
			for each (var item:* in itemTypesData) {
				trace(item);
			}
		}
		
		
		// наименование типа объекта
		protected var _itemType:String;
		public function get itemType():String { return _itemType; }
		
		// размер объекта
		protected var _size:Array;
		public function get size():Array { return _size; }
		
		// максимальный уровень
		protected var _maxLevel:uint;
		public function get maxLevel():uint { return _maxLevel; }
		
		// данные о изображениях объекта
		protected var _imagesData:Object;
		
		// -- конструктор
		public function ItemType(itemType:String, data:XML)
		{
			_itemType = itemType;
			
			_size = [1, 1];
			
			_maxLevel = 5;
			
			_imagesData = { "1": new SkinData(itemType, 1, 0, 0, true) };
		}
		
		// получение данных о скине объекта
		public function getImageData(level:uint):SkinData
		{
			return _imagesData[level];
		}
		
		
	}
}