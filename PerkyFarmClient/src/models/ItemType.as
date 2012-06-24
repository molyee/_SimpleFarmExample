package models
{
	/**
	 * класс типов элементов карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ItemType
	{
		
		public static const ITEM_TYPES:Object = { };
		
		public static function getItemTypeData(itemType:String):ItemType
		{
			return ITEM_TYPES[itemType];
		}
		
		public static function initItemTypes(itemTypesData:XML):void
		{
			SkinData.ITEM_IMAGES_FORMAT = itemTypesData.@imgFormat;
			SkinData.ITEM_IMAGES_PATH = itemTypesData.@imagesPath;
			for each (var item:XML in itemTypesData..itemType) {
				var name:String = item.@name;
				ITEM_TYPES[item.@name] = new ItemType(name, item);
			}
		}
		
		
		// наименование типа объекта
		protected var _name:String;
		public function get name():String { return _name; }
		
		// размер объекта
		protected var _size:Array;
		public function get size():Array { return _size; }
		
		// максимальный уровень
		protected var _maxLevel:uint;
		public function get maxLevel():uint { return _maxLevel; }
		
		// данные о изображениях объекта
		protected var _imagesData:Object;
		
		// -- конструктор
		public function ItemType(name:String, data:XML)
		{
			_name = name;
			_size = [int(data.@w), int(data.@h)];
			_maxLevel = data.@levels;
			_imagesData = { };
			for each (var img:XML in data..img) {
				var level:uint = uint(img.@id);
				var offsetX:int = int(img.@x);
				var offsetY:int = int(img.@y);
				var isDefault:Boolean = Boolean(int(img.@def) != 0);
				_imagesData[level] = new SkinData(_name, level, offsetX, offsetY, isDefault);
			}
		}
		
		// получение данных о скине объекта
		public function getImageData(level:uint):SkinData
		{
			return _imagesData[level];
		}
		
		// получение данных о миниатюрном изображении
		public function getIconUrl():String
		{
			for each (var skin:SkinData in _imagesData) {
				if (skin.isDefault)
					return skin.url;
			}
			return (_imagesData[1] as SkinData).url;
		}
	}
}