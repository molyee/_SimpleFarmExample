package views.panels 
{
	import controllers.IConnectionController;
	import events.ObjectEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import models.ItemType;
	import views.controls.buttons.ItemTypeIcon;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ItemSelectPanel extends Sprite 
	{
		public static const PANEL_WIDTH:int = 385;
		public static const PANEL_HEIGHT:int = 100;
		
		public static const PANEL_HIDDEN_DELTA:int = 90;
		public static const ANIM_SPEED:Number = 0.85;
		
		protected static const PADDING_X:int = 15;
		protected static const PADDING_Y:int = 15;
		protected static const CELL_SPACING:int = 10;
		
		protected var _holder:Sprite;
		
		protected var _animated:Boolean;
		
		protected var _enabled:Boolean = true;
		public function get enabled():Boolean { return _enabled; }
		
		public function ItemSelectPanel() 
		{
			_holder = new Sprite();
			this.addChild(_holder);
			
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(3, 0x666666, 1);
			shape.graphics.beginFill(0x33cc00);
			shape.graphics.drawRoundRect(0, 0, PANEL_WIDTH, PANEL_HEIGHT + PADDING_Y, PADDING_X, PADDING_Y);
			shape.graphics.endFill();
			var bounds:Rectangle = shape.getBounds(shape);
			var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00000000);
			bitmapData.draw(shape, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
			var background:Bitmap = new Bitmap(bitmapData);
			_holder.addChild(background);
			
			if (stage) init();
			else this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(event:Event = null):void
		{
			if (event)
				(event.currentTarget as IEventDispatcher).removeEventListener(Event.ADDED_TO_STAGE, init);
			resize(stage.stageWidth, stage.stageHeight);
		}
		
		public function updateItemTypes(itemTypesData:Object):void
		{
			var itemType:ItemType;
			var icon:ItemTypeIcon;
			var xpos:int = PADDING_X;
			var ypos:int = PADDING_Y;
			for (var itemTypeID:String in itemTypesData) {
				itemType = itemTypesData[itemTypeID] as ItemType;
				icon = new ItemTypeIcon(itemType);
				icon.x = xpos;
				icon.y = ypos;
				xpos += icon.width + CELL_SPACING;
				icon.addEventListener(MouseEvent.CLICK, clickItemHandler);
				_holder.addChild(icon);
			}
			if (stage) init();
		}
		
		protected function clickItemHandler(event:MouseEvent):void
		{
			var icon:ItemTypeIcon = event.currentTarget as ItemTypeIcon;
			select(icon.itemType);
		}
		
		public function show():void
		{
			if (_enabled) return;
			_enabled = true;
			if (_animated) return;
			_animated = true;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		public function hide():void
		{
			if (!_enabled) return;
			_enabled = false;
			if (_animated) return;
			_animated = true;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			var targetY:Number = _enabled ? 0 : PANEL_HIDDEN_DELTA 
			_holder.y = targetY - (targetY - _holder.y) * ANIM_SPEED;
			if (Math.abs(targetY - _holder.y) > 0.1) return;
			_holder.y = targetY;
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_animated = false;
		}
		
		public function select(itemType:ItemType):void
		{
			trace(itemType.name + " selected");
			dispatchEvent(new ObjectEvent(Event.SELECT, itemType));
		}
		
		public function resize(width:Number, height:Number):void
		{
			this.x = (width - this.width) / 2;
			this.y = height - PANEL_HEIGHT;
		}
	}

}