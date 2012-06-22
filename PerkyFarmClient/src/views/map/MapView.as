package views.map
{
	import display.utils.Isometric;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class MapView extends Sprite
	{
		[Embed(source="../../../media/grass_texture.jpg")]
		protected var BackTexture:Class;
		
		protected var backgroundLayer:Sprite;
		protected var tilesLayer:Sprite;
		protected var itemsLayer:Sprite;
		
		public function MapView(width:Number, height:Number)
		{
			super();
			
			Isometric.MAP_WIDTH = width;
			Isometric.MAP_HEIGHT = height;
			
			var texture:BitmapData = new BackTexture() as BitmapData;
			backgroundLayer = new Sprite();
			//backgroundLayer.graphics.beginBitmapFill(
			
			tilesLayer = new Sprite();
			itemsLayer = new Sprite();
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event = null):void
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			
		}
		
		protected function removedFromStage(event:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			
		}
		
		public function resize(width:Number, height:Number):void
		{
			
		}
	}
}