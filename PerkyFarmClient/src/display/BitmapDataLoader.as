package display 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class BitmapDataLoader extends EventDispatcher 
	{
		
		public function BitmapDataLoader(url:String, callback:Function) 
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x33cc00, 1);
			shape.graphics.moveTo(0, 25);
			shape.graphics.lineTo(50, 0);
			shape.graphics.lineTo(100, 25);
			shape.graphics.lineTo(50, 50);
			shape.graphics.endFill();
			var bitmapData:BitmapData = new BitmapData(100, 50, true, 0x00000000);
			bitmapData.draw(shape);
			callback(bitmapData);
		}
		
	}

}