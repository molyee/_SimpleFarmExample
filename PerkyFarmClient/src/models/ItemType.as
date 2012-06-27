package models
{
	/**
	 * Класс типов элементов карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ItemType
	{
		/**
		 * Объект содержащий подгружаемые данные о типах объектов карты
		 * 
		 */
		public static const ITEM_TYPES:Object = { };
		
		/**
		 * Получение данных о типе объекта карты
		 * 
		 * @param	itemType Идентификатор типа объекта
		 * @return Объект описывающий шаблон объекта карты
		 */
		public static function getItemTypeData(itemType:String):ItemType
		{
			return ITEM_TYPES[itemType];
		}
		
		/**
		 * Инициализация типов данных из полученной XML
		 * 
		 * @param	itemTypesData Загруженные данные о типах в формате XML
		 */
		public static function initItemTypes(itemTypesData:XML):void
		{
			SkinData.ITEM_IMAGES_FORMAT = itemTypesData.@imgFormat;
			SkinData.ITEM_IMAGES_PATH = itemTypesData.@imagesPath;
			for each (var item:XML in itemTypesData..itemType) {
				var name:String = item.@name;
				ITEM_TYPES[item.@name] = new ItemType(name, item);
			}
		}
		
		protected var _name:String;
		/**
		 * Наименование типа объекта
		 * 
		 */
		public function get name():String { return _name; }
		
		protected var _size:Array;
		/**
		 * Размер объекта
		 * 
		 */
		public function get size():Array { return _size; }
		
		protected var _maxLevel:uint;
		/**
		 * Максимальный уровень объекта
		 * 
		 */
		public function get maxLevel():uint { return _maxLevel; }
		
		/**
		 * Данные о изображениях объекта
		 * @private
		 */
		protected var _imagesData:Object;
		
		/**
		 * Конструктор шаблона объектов
		 * 
		 * @param	name Наименование типа объекта
		 * @param	data Данные шаблона объекта
		 */
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
		
		/**
		 * Получение данных о скине объекта
		 * 
		 */
		public function getImageData(level:uint):SkinData
		{
			return _imagesData[level];
		}
		
		/**
		 * Получение данных о миниатюрном изображении
		 * 
		 * @return URL-адрес или идентификатор иконки шаблона (то, что отображается в меню покупки объекта)
		 */
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