package views.map 
{
	import display.ImageLoader;
	import display.utils.ColorMatrix;
	import flash.geom.Point;
	import math.Isometric;
	import models.Item;
	import models.ItemType;
	import models.SkinData;
	
	/**
	 * Простой класс заместитель визуального объекта карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class MapSurrogateView extends ImageLoader implements IMapObjectView
	{
		protected var _xpos:int;
		/**
		 * X-позиция ячейки привязки к карте
		 * 
		 */
		public function get xpos():int { return _xpos; }
		
		protected var _ypos:int;
		/**
		 * Y-позиция ячейки привязки к карте
		 * 
		 */
		public function get ypos():int { return _ypos; }
		
		/**
		 * Ширина объекта в ячейках карты (размер X)
		 * 
		 */
		public function get w():int { return _itemType.size[0]; }
		
		/**
		 * Высота объекта в ячейках карты (размер Y)
		 * 
		 */
		public function get h():int { return _itemType.size[1]; }
		
		protected var _enabled:Boolean;
		/**
		 * Триггер доступности действий с объектом
		 * 
		 */
		public function get enabled():Boolean { return _enabled; }
		/**
		 * Установщик флага доступности объекта
		 * @private
		 */
		public function set enabled(value:Boolean):void {
			if (_enabled == value) return;
			_enabled = value;
			if (_enabled)
				filters = null;
			else
				filters = ColorMatrix.BLACK_AND_WHITE_FILTERS;
		}
		
		/**
		 * Идентификатор модели объекта карты (не используется)
		 * @private
		 */
		public function get itemID():String { return null; }
		
		/**
		 * Ссылка на модель объекта карты (не используется)
		 * @private
		 */
		public function get mapObject():Item { return null; }
		
		protected var _itemType:ItemType;
		/**
		 * Тип объекта карты
		 * 
		 */
		public function get itemType():ItemType { return _itemType; }
		
		/**
		 * Конструктор класса
		 * 
		 * @param	itemType Данные типа объекта
		 * 
		 */
		public function MapSurrogateView(itemType:ItemType) 
		{
			_itemType = itemType;
			var imageData:SkinData = itemType.getImageData(1);
			var imageUrl:String = imageData.url;
			super(imageUrl, null, true, imageData.offsetX, imageData.offsetY);
			this.alpha = 0.7;
		}
		
		/**
		 * Установка позиции суррогата в ячейку на карте
		 * 
		 * @param	xpos X-позиция ячейки
		 * @param	ypos Y-позиция ячейки
		 * 
		 */
		public function setPosition(xpos:int, ypos:int):void
		{
			_xpos = xpos;
			_ypos = ypos;
			var pos:Point = Isometric.normalToIsometric(_xpos, _ypos);
			x = pos.x;
			y = pos.y;
		}
		
		/**
		 * Деструктор объекта
		 * 
		 */
		override public function dispose():void
		{
			super.dispose();
			_itemType = null;
		}
		
	}

}