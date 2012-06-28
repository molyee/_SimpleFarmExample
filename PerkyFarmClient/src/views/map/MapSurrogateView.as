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
		
		public function get w():int { return _itemType.size[0]; }
		public function get h():int { return _itemType.size[1]; }
		
		protected var _enabled:Boolean;
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			if (_enabled == value) return;
			_enabled = value;
			if (_enabled)
				filters = null;
			else
				filters = ColorMatrix.BLACK_AND_WHITE_FILTERS;
		}
		
		public function get itemID():String { return null; }
		
		public function get mapObject():Item { return null; }
		
		protected var _itemType:ItemType;
		public function get itemType():ItemType { return _itemType; }
		
		public function MapSurrogateView(itemType:ItemType) 
		{
			_itemType = itemType;
			var imageData:SkinData = itemType.getImageData(1);
			var imageUrl:String = imageData.url;
			super(imageUrl, null, true, imageData.offsetX, imageData.offsetY);
			this.alpha = 0.7;
		}
		
		public function setPosition(xpos:int, ypos:int):void
		{
			_xpos = xpos;
			_ypos = ypos;
			var pos:Point = Isometric.normalToIsometric(_xpos, _ypos);
			x = pos.x;
			y = pos.y;
		}
		
		override public function dispose():void
		{
			super.dispose();
			_itemType = null;
		}
		
	}

}