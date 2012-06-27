package views.map 
{
	import display.utils.BitmapCache;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	
	/**
	 * Класс организующий загрузку и создание фоновой картинки
	 * ...
	 * @author Alex Sarapulov
	 */
	public class BackgroundLayer
	{
		/**
		 * Контейнер для текстуры
		 * @private
		 */
		protected var _holder:DisplayObjectContainer;
		
		/**
		 * Растровые данные текстуры
		 * 
		 * @private
		 */
		protected var _texture:BitmapData;
		
		/**
		 * Объект отрисовки фона
		 * @private
		 */
		protected var _background:Bitmap;
		
		protected var _width:Number;
		/**
		 * Ширина заливки
		 * 
		 */
		public function get width():Number { return _width; }
		
		protected var _height:Number;
		/**
		 * Высота заливки
		 * 
		 */
		public function get height():Number { return _height; }
		
		/**
		 * Триггер показа фона
		 * @private
		 */
		protected var _showing:Boolean;
		
		
		/**
		 * Конструктор класса уровня фона
		 * 
		 * @param	holder Контейнер для фоновой картинки
		 * @param	texture Растровые данные фоновой текстуры
		 * @param	width Ширина фона
		 * @param	height Высота фона
		 * 
		 */
		public function BackgroundLayer(holder:DisplayObjectContainer, texture:BitmapData = null, width:Number = 0, height:Number = 0) 
		{
			_holder = holder;
			_background = new Bitmap();
			if (texture)
				setTexture(texture);
			setSize(width, height);
		}
		
		/**
		 * Применение текстуры
		 * 
		 * @param	texture Растровые данные о текстуре
		 * 
		 */
		public function setTexture(texture:BitmapData):void
		{
			_texture = texture;
			if (_showing)
				update();
		}
		
		/**
		 * Обновление размера фоновой заливки
		 * 
		 * @param	width Значение ширины фона
		 * @param	height Значение высоты фона
		 * 
		 */
		public function setSize(width:Number, height:Number):void
		{
			if (_width == width && _height == height)
				return;
			_width = width;
			_height = height;
			if (_showing)
				update();
		}
		
		/**
		 * Показ фоновой картинки
		 * 
		 */
		public function show():void
		{
			if (_showing) return;
			_showing = true;
			_holder.addChildAt(_background, 0);
			if (_width == 0 || _height == 0 || _texture == null)
				return;
			update();
		}
		
		/**
		 * Скрытие фона (удаление из списка отображения)
		 * 
		 */
		public function hide():void
		{
			if (!_showing) return;
			_showing = false;
			if (_background.parent)
				_background.parent.removeChild(_background);
		}
		
		/**
		 * Обновление фоновой картинки
		 * @private
		 */
		protected function update():void
		{
			var shape:Shape = new Shape();
			shape.graphics.clear();
			shape.graphics.beginBitmapFill(_texture);
			shape.graphics.drawRect(0, 0, _width, _height);
			shape.graphics.endFill();
			
			_background.bitmapData = BitmapCache.drawBitmapData(shape);
		}
	}

}