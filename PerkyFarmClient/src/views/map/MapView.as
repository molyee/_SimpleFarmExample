package views.map
{
	import display.utils.Isometric;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class MapView extends Sprite
	{
		// -- уровни
		protected var backgroundLayer:BackgroundLayer; // уровень фона
		protected var tilesLayer:Sprite; // уровень ячеек
		protected var itemsLayer:Sprite; // уровень объектов
		
		// текущий размер сцены
		protected var _stageWidth:Number;
		protected var _stageHeight:Number;
		
		// максимальное расстояние смещения карты (при перетаскивании),
		// учитывающее отпускание кнопки мыши как клик
		protected static const DRAG_DEMPER:Number = 5;
		
		protected var _lastPosition:Point; // предыдущее положение курсора мыши на сцене (при перемещении карты)
		protected var _downPosition:Point; // позиция на сцене, на которой была нажата кнопка мыши
		protected var _dragging:Boolean = false; // состояние перетаскивания карты
		protected var _dragEnabled:Boolean = true; // триггер доступности функции перемещения карты с помощью мыши
		
		// -- конструктор
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
		
		// обработчик события добавление карты на сцену
		protected function addedToStageHandler(event:Event = null):void
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			resize(stage.stageWidth, stage.stageHeight);
			backgroundLayer.show();
			
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		// обработчик события удаление карты со сцены
		protected function removedFromStage(event:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			this.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			backgroundLayer.hide();
		}
		
		// обработчик события опускания кнопки мыши
		protected function mouseDownHandler(event:MouseEvent):void
		{
			_downPosition = new Point(event.stageX, event.stageY);
			_lastPosition = new Point(event.stageX, event.stageY);
			this.addEventListener(Event.ENTER_FRAME, draggingHandler);
		}
		
		// обработчик события поднятия кнопки мыши
		protected function mouseUpHandler(event:MouseEvent):void
		{
			this.removeEventListener(Event.ENTER_FRAME, draggingHandler);
			if (!_dragging) {
				clickHandler(event);
				return;
			}
			_dragging = false;
			_downPosition = null;
			_lastPosition = null;
		}
		
		// обработчик события перемещения мыши на сцене
		protected function draggingHandler(event:Event):void
		{
			var deltaX:Number;
			var deltaY:Number;
			if (!_dragging) {
				deltaX = Math.abs(stage.mouseX - _downPosition.x);
				deltaY = Math.abs(stage.mouseY - _downPosition.y);
				_dragging = deltaX > DRAG_DEMPER || deltaY > DRAG_DEMPER;
			}
			if (!_dragEnabled) return;
			
			deltaX = stage.mouseX - _lastPosition.x;
			deltaY = stage.mouseY - _lastPosition.y;
			_lastPosition.x = stage.mouseX;
			_lastPosition.y = stage.mouseY;
			
			moveTo(x + deltaX, y + deltaY);
		}
		
		// обработчик события клика по сцене
		protected function clickHandler(event:MouseEvent):void
		{
			trace("clicked");
		}
		
		// центрирование карты вокруг точки на карте
		public function centerOn(xpos:Number, ypos:Number):void
		{
			var _x:Number = xpos + (_stageWidth) / 2 - backgroundLayer.width;
			var _y:Number = ypos + (_stageHeight) / 2 - backgroundLayer.height;
			moveTo(_x, _y);
		}
		
		// перемещение карты на заданную позицию
		protected function moveTo(xpos:Number, ypos:Number):void
		{
			if (xpos > 0) xpos = 0;
			if (ypos > 0) ypos = 0;
			if (xpos < _stageWidth - backgroundLayer.width)
				xpos = _stageWidth - backgroundLayer.width;
			if (ypos < _stageHeight - backgroundLayer.height)
				ypos = _stageHeight - backgroundLayer.height;
			x = xpos;
			y = ypos;
		}
		
		// обработчик изменения размера контейнера
		public function resize(width:Number, height:Number):void
		{
			_stageWidth = stage.stageWidth;
			_stageHeight = stage.stageHeight;
			
			var backWidth:Number = Math.max(Isometric.MAP_WIDTH, _stageWidth);
			var backHeight:Number = Math.max(Isometric.MAP_HEIGHT, _stageHeight);
			backgroundLayer.setSize(backWidth, backHeight);
			
			// фокусируем на центральной точке карты (можно на каком-либо объекте)
			centerOn(Isometric.MAP_WIDTH / 2, Isometric.MAP_HEIGHT / 2); 
		}
	}
}