package display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	[Event(name="complete", type="flash.events.Event")]
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ImageLoader extends Sprite 
	{
		protected var _size:Point;
		
		protected var _centered:Boolean;
		
		protected var _offsetX:Number;
		
		protected var _offsetY:Number;
		
		protected var _bitmapData:BitmapData;
		
		protected var _bitmap:Bitmap;
		
		protected var _disposed:Boolean;
		
		public function ImageLoader(url:String, size:Point = null, centered:Boolean = true, offsetX:Number = 0, offsetY:Number = 0) 
		{
			_size = size;
			_centered = centered;
			_offsetX = offsetX;
			_offsetY = offsetY;
			
			var bitmapDataLoader:BitmapDataLoader = new BitmapDataLoader(url, loadHandler);
		}
		
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