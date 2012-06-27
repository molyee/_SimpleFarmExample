package models 
{
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class SkinData 
	{
		/**
		 * Путь к контейнеру изображений
		 * 
		 */
		public static var ITEM_IMAGES_PATH:String;
		
		/**
		 * Формат изображений
		 * 
		 */
		public static var ITEM_IMAGES_FORMAT:String;
		
		protected var _itemType:String;
		/**
		 * Тип объекта
		 * 
		 */
		public function get itemType():String { return _itemType; }
		
		protected var _level:uint = 1;
		/**
		 * Уровень объекта
		 * 
		 */
		public function get level():uint { return _level; }
		
		protected var _isDefault:Boolean;
		/**
		 * Триггер, указывающий на то, является ли изображение иконкой объекта
		 * 
		 */
		public function get isDefault():Boolean { return _isDefault; }
		
		protected var _offsetX:int;
		/**
		 * Смещение изображения в пикселях по оси X без масштабирования
		 * 
		 */
		public function get offsetX():int { return _offsetX; }
		
		protected var _offsetY:int;
		/**
		 * Смещение изображения в пикселях по оси Y без масштабирования
		 * 
		 */
		public function get offsetY():int { return _offsetY; }
		
		protected var _url:String;
		/**
		 * URL-адрес или идентификатор изображения
		 * 
		 */
		public function get url():String { return _url; }
		
		/**
		 * Конструктор данных о изображении объекта
		 * 
		 * @param	itemType Наименование типа объекта
		 * @param	level Уровень объекта
		 * @param	offsetX Смещение изображения по X
		 * @param	offsetY Смещение изображения по Y
		 * @param	isDefault Триггер, указывающий на то, является ли изображением по умолчанию
		 */
		public function SkinData(itemType:String, level:uint = 1, offsetX:int = 0, offsetY:int = 0, isDefault:Boolean = false) 
		{
			_itemType = itemType;
			_level = level;
			_offsetX = offsetX;
			_offsetY = offsetY;
			_isDefault = isDefault;
			_url = ITEM_IMAGES_PATH + "/" + itemType + "/" + level + "." + ITEM_IMAGES_FORMAT;
		}
		
	}

}