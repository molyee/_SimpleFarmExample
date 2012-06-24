package display 
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class BitmapDataLoader 
	{
		public static var STORAGE:ResourceStorage;
		
		public function BitmapDataLoader(url:String, callback:Function) 
		{
			if (!STORAGE) throw("Resource storage is unavailable");
			STORAGE.getResource(url, callback);
		}
		
	}

}