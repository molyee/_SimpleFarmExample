package views.controls.buttons 
{
	import display.ImageLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import models.ItemType;
	import models.SkinData;
	
	/**
	 * Класс отображения иконки в меню выбора объектов карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ItemTypeIcon extends ImageLoader 
	{
		/**
		 * Стандартный размер иконки
		 * @private
		 */
		protected static const ICON_SIZE:Point = new Point(70, 70);
		
		/**
		 * Стандартный размер фона иконки
		 * @private
		 */
		protected static const BACKGROUND_SIZE:Point = new Point(80, 80);
		
		/**
		 * Растровые данные фона
		 * @private
		 */
		protected static var BACKGROUND_BITMAP_DATA:BitmapData;
		
		protected var _itemType:ItemType;
		/**
		 * Данные о типе объекта
		 * 
		 */
		public function get itemType():ItemType { return _itemType; }
		
		/**
		 * Конструктор класса иконки объектов
		 * 
		 * @param	itemType Данные о типе объекта
		 */
		public function ItemTypeIcon(itemType:ItemType) 
		{
			_itemType = itemType;
			if (!BACKGROUND_BITMAP_DATA) {
				prepareBackground();
			}
			var background:Bitmap = new Bitmap(BACKGROUND_BITMAP_DATA);
			this.addChild(background);
			
			this.addEventListener(Event.COMPLETE, completeLoadingHandler);
			var iconData:SkinData = _itemType.getImageData(1);
			super(_itemType.getIconUrl(), ICON_SIZE, true);
		}
		
		/**
		 * Обработчик события загрузки картинки
		 * 
		 * @param	event Событие завершение загрузки
		 * @private
		 */
		private function completeLoadingHandler(event:Event):void 
		{
			this.removeEventListener(Event.COMPLETE, completeLoadingHandler);
			_bitmap.x += BACKGROUND_BITMAP_DATA.width / 2;
			_bitmap.y += BACKGROUND_BITMAP_DATA.height / 2;
		}
		
		/**
		 * Подготовка стандартного фона иконки при первом запросе
		 * @private
		 */
		protected function prepareBackground():void
		{
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(2, 0x339900);
			shape.graphics.beginFill(0xffffff, 1);
			shape.graphics.drawRoundRect(0, 0, BACKGROUND_SIZE.x, BACKGROUND_SIZE.y, 15, 15);
			shape.graphics.endFill();
			var bounds:Rectangle = shape.getBounds(shape);
			BACKGROUND_BITMAP_DATA = new BitmapData(bounds.width, bounds.height, true, 0x00000000);
			BACKGROUND_BITMAP_DATA.draw(shape, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
		}
		
		/**
		 * Деструктор объекта иконки
		 * 
		 */
		override public function dispose():void
		{
			super.dispose();
			_itemType = null;
		}
	}

}