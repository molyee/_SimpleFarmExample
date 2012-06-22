package views.map
{
	import display.utils.Isometric;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class MapView extends Sprite
	{
		protected var backgroundLayer:BackgroundLayer;
		protected var tilesLayer:Sprite;
		protected var itemsLayer:Sprite;
		
		public function MapView(width:Number, height:Number)
		{
			super();
			
			Isometric.MAP_WIDTH = width;
			Isometric.MAP_HEIGHT = height;
			
			backgroundLayer = new BackgroundLayer(this, null, width, height);
			
			tilesLayer = new Sprite();
			itemsLayer = new Sprite();
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event = null):void
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			backgroundLayer.show();
		}
		
		protected function removedFromStage(event:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			backgroundLayer.hide();
		}
		
		public function resize(width:Number, height:Number):void
		{
			
		}
	}
}