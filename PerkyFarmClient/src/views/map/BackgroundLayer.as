package views.map 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class BackgroundLayer
	{
		[Embed(source="../../../media/grass_texture.jpg")]
		public static const DEFAULT_TEXTURE_CLASS:Class; // текстура фона по умолчанию
		
		// контейнер для текстуры
		protected var _holder:DisplayObjectContainer;
		
		// растровые данные текстуры
		protected var _texture:BitmapData;
		
		// объект отрисовки фона
		protected var _background:Bitmap;
		
		// ширина заливки
		protected var _width:Number;
		public function get width():Number { return _width; }
		
		// высота заливки
		protected var _height:Number;
		public function get height():Number { return _height; }
		
		// триггер показа фона
		protected var _showing:Boolean;
		
		// -- конструктор
		public function BackgroundLayer(holder:DisplayObjectContainer, texture:BitmapData = null, width:Number = 0, height:Number = 0) 
		{
			_holder = holder;
			_background = new Bitmap();
			if (!texture)
				texture = (new DEFAULT_TEXTURE_CLASS() as Bitmap).bitmapData;
			setTexture(texture);
			setSize(width, height);
		}
		
		// обновление текстуры
		public function setTexture(texture:BitmapData):void
		{
			_texture = texture;
			if (_showing)
				update();
		}
		
		// обновление размера фоновой заливки
		public function setSize(width:Number, height:Number):void
		{
			if (_width == width && _height == height)
				return;
			_width = width;
			_height = height;
			if (_showing)
				update();
		}
		
		// показ фона
		public function show():void
		{
			if (_width == 0 || _height == 0 || _texture == null) {
				CONFIG::debug {
					throw("Background texture not prepared");
				}
				return;
			}
			if (_showing) return;
			_showing = true;
			update();
			_holder.addChildAt(_background, 0);
		}
		
		// скрытие фона (удаление из списка отображения)
		public function hide():void
		{
			if (!_showing) return;
			_showing = false;
			if (_background.parent)
				_background.parent.removeChild(_background);
		}
		
		// обновление текстуры фона
		protected function update():void
		{
			var shape:Shape = new Shape();
			shape.graphics.clear();
			shape.graphics.beginBitmapFill(_texture);
			shape.graphics.drawRect(0, 0, _width, _height);
			shape.graphics.endFill();
			
			var bitmapData:BitmapData = new BitmapData(_width, _height, false, 0xffffff);
			bitmapData.draw(shape);
			_background.bitmapData = bitmapData;
		}
	}

}