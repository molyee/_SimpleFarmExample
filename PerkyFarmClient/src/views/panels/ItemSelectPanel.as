package views.panels 
{
	import controllers.IConnectionController;
	import display.utils.BitmapCache;
	import events.ObjectEvent;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import models.ItemType;
	import views.controls.buttons.ItemTypeIcon;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ItemSelectPanel extends Sprite 
	{
		// константы размеров панели выбора объектов
		public static const PANEL_WIDTH:int = 385;
		public static const PANEL_HEIGHT:int = 100;
		
		// константы управления сворачиванием и разворачиванием панели
		public static const PANEL_HIDDEN_DELTA:int = 90;
		public static const ANIM_SPEED:Number = 0.85;
		
		// отступ внутренних элементов от края панели
		protected static const PADDING_X:int = 15;
		protected static const PADDING_Y:int = 15;
		// дистанция между элементами панели
		protected static const CELL_SPACING:int = 10;
		
		// родительский контейнер
		protected var _holder:Sprite;
		
		// состояние включенной анимации (true)
		protected var _animated:Boolean;
		
		// триггер доступности действий
		protected var _enabled:Boolean = true;
		public function get enabled():Boolean { return _enabled; }
		
		// -- конструктор
		public function ItemSelectPanel() 
		{
			_holder = new Sprite();
			this.addChild(_holder);
			
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(3, 0x666666, 1);
			shape.graphics.beginFill(0x33cc00);
			shape.graphics.drawRoundRect(0, 0, PANEL_WIDTH, PANEL_HEIGHT + PADDING_Y, PADDING_X, PADDING_Y);
			shape.graphics.endFill();
			var background:Bitmap = BitmapCache.drawBitmap(shape);
			_holder.addChild(background);
			
			if (stage) init();
			else this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// обработчик добавления панели на сцену
		protected function init(event:Event = null):void
		{
			if (event)
				(event.currentTarget as IEventDispatcher).removeEventListener(Event.ADDED_TO_STAGE, init);
			resize(stage.stageWidth, stage.stageHeight);
		}
		
		// обновление списка элементов в панели
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
		
		// обработчик клика по элементу в списке панели
		protected function clickItemHandler(event:MouseEvent):void
		{
			var icon:ItemTypeIcon = event.currentTarget as ItemTypeIcon;
			select(icon.itemType);
		}
		
		// показать панель
		public function show():void
		{
			if (_enabled) return;
			_enabled = true;
			if (_animated) return;
			_animated = true;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		// скрыть панель
		public function hide():void
		{
			if (!_enabled) return;
			_enabled = false;
			if (_animated) return;
			_animated = true;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		// обработчик событий входа в кадр для создания анимации движения
		protected function enterFrameHandler(event:Event):void
		{
			var targetY:Number = _enabled ? 0 : PANEL_HIDDEN_DELTA 
			_holder.y = targetY - (targetY - _holder.y) * ANIM_SPEED;
			if (Math.abs(targetY - _holder.y) > 0.1) return;
			_holder.y = targetY;
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_animated = false;
		}
		
		// выбор объекта в списке элементов
		public function select(itemType:ItemType):void
		{
			trace(itemType.name + " selected");
			dispatchEvent(new ObjectEvent(Event.SELECT, itemType));
		}
		
		// обработчик изменения размеров контейнера
		public function resize(width:Number, height:Number):void
		{
			this.x = (width - this.width) / 2;
			this.y = height - PANEL_HEIGHT;
		}
	}

}