package display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * Класс загрузки растровых объектов и добавления их в список отображения
	 * с заранее заданными параметрами размерности, смещения растровых данных и
	 * центрирования относительно начала координат текущего объекта-контейнера
	 * ...
	 * @author Alex Sarapulov
	 */
	[Event(name="complete", type="flash.events.Event")]
	public class ImageLoader extends Sprite 
	{
		/**
		 * Размер картинки, к которому должен быть приведен полученный растровый объект
		 * 
		 */
		protected var _size:Point;
		
		/**
		 * Флаг центрирования растрового объекта относительно начала координат объекта-контейнера
		 * 
		 */
		protected var _centered:Boolean;
		
		/**
		 * Смещение растрового объекта по X-оси
		 * 
		 */
		protected var _offsetX:Number;
		
		/**
		 * Смещение растрового объекта по Y-оси
		 * 
		 */
		protected var _offsetY:Number;
		
		/**
		 * Загруженные растровые данные
		 * 
		 */
		protected var _bitmapData:BitmapData;
		
		/**
		 * Созданные растровый объект, добавленный в список отображения текущего объекта-контейнера
		 * 
		 */
		protected var _bitmap:Bitmap;
		
		/**
		 * Флаг финализации объекта (нужен, для обозначения реакции на финализацию класса в случае
		 * запуска деструктора во время загрузки растровых данных.
		 * 
		 */
		protected var _disposed:Boolean;
		
		/**
		 * Конструктор загрузчика растровых данных
		 *  
		 * @param	url URL-адрес или идентификатор растровой картинки
		 * @param	size Размер растровой картинки, который должен быть применен к изображению после добавления его на сцену
		 * @param	centered Флаг центрирования изображения относительно начала координат объекта-контейнер
		 * @param	offsetX Смещение растрового объекта по X-оси
		 * @param	offsetY Смещение растрового объекта по Y-оси
		 * 
		 */
		public function ImageLoader(url:String, size:Point = null, centered:Boolean = true, offsetX:Number = 0, offsetY:Number = 0) 
		{
			_size = size;
			_centered = centered;
			_offsetX = offsetX;
			_offsetY = offsetY;
			
			var bitmapDataLoader:BitmapDataLoader = new BitmapDataLoader(url, loadHandler);
		}
		
		/**
		 * Обработчик загрузки растровых данных
		 * 
		 * @param	data Растровые данные загруженного ресурса
		 * @private
		 */
		protected function loadHandler(data:BitmapData):void
		{
			if (_disposed) return;
			
			_bitmapData = data;
			_bitmap = new Bitmap(_bitmapData, "auto", _size != null);
			if (_size) {
				var scale:Number = Math.min(_size.x / _bitmap.width, _size.y / _bitmap.height);
				_bitmap.scaleX = _bitmap.scaleY = scale;
				_offsetX *= scale;
				_offsetY *= scale;
			}
			_bitmap.x = _offsetX;
			_bitmap.y = _offsetY;
			if (_centered) {
				_bitmap.x -= _bitmap.width / 2;
				_bitmap.y -= _bitmap.height / 2;
			}
			this.addChild(_bitmap);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Деструктор объекта загрузчика
		 * (любую подписку на события объекта следует удалять из класса, который создал эту подписку)
		 * 
		 */
		public function dispose():void
		{
			_disposed = true;
			while (numChildren > 0) {
				this.removeChildAt(0);
			}
			_size = null;
			_bitmapData = null;
			_bitmap = null;
		}
		
	}

}