package views.map
{
	import controllers.ClientConnectionController;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import math.DoubleIndexInserter;
	import math.Isometric;
	import models.Item;
	import models.ItemType;
	import models.Model;
	import models.User;
	
	public class MapView extends Sprite
	{
		/** Константа нормального состояния вида карты */
		public static const NORMAL_STATE:String = "normal";
		/** Константа состояния активации постройки */
		public static const PLACING_STATE:String = "placing";
		/** Константа состояния перемещения постройки */
		public static const MOVING_STATE:String = "moving";
		
		// текущее состояние
		protected var _currentState:String = "normal";
		public function get currentState():String { return _currentState; }
		
		
		// -- уровни
		protected var backgroundLayer:BackgroundLayer; // уровень фона
		protected var tilesLayer:TilesLayer; // уровень ячеек
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
		
		// точка на карте, на которую следует фокусироваться
		protected var _target:Point; 
		
		// заместитель строящегося объекта
		protected var _currentMapObject:IMapObjectView;
		
		protected var _moving:Boolean;
		
		protected var _items:Object = { };
		
		// ссылка на контроллер
		protected var _controller:ClientConnectionController;
		
		// ссылка на текущего пользователя
		protected var _currentUser:User;
		public function get currentUser():User { return _currentUser; }
		public function set currentUser(value:User):void {
			_currentUser = value;
			tilesLayer.objectsMap = _currentUser.map;
			var items:Object = _currentUser.items;
			for (var itemID:String in items) {
				var item:Item = items[itemID] as Item;
				var mapObjectView:MapObjectView = new MapObjectView(item);
				addItemHander(mapObjectView);
			}
		}
		
		protected var _indexInserter:DoubleIndexInserter;
		
		
		// -- конструктор
		public function MapView(controller:ClientConnectionController, size:int)
		{
			super();
			
			MapObjectView.MAP_VIEW = this;
			
			_indexInserter = new DoubleIndexInserter(Isometric.PADDING_Y, Isometric.MAP_HEIGHT + 2*Isometric.PADDING_Y, "y", 15, DoubleIndexInserter.LINEAR);
			
			_controller = controller;
			_items = { };
			_target = new Point();
			
			backgroundLayer = new BackgroundLayer(this);
			
			itemsLayer = new Sprite();
			this.addChild(itemsLayer);
			
			tilesLayer = new TilesLayer(size);
			this.addChild(tilesLayer);
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		// обновление текстуры фона
		public function setBackgroundTexture(texture:BitmapData):void
		{
			backgroundLayer.setTexture(texture);
		}
		
		// установка состояния (строительсто или норма)
		public function setState(state:String, data:* = null):void
		{
			if (_currentState == state) return;
			_currentState = state;
			itemsLayer.mouseChildren = _currentState == NORMAL_STATE;
			if (state == PLACING_STATE) {
				createSurrogate(data as ItemType);
			} else {
				if (state != MOVING_STATE)
					stopMovingObject();
				else
					_moving = false;
			}
			//trace("set map state", state);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		// создание псевдообъекта, который может быть построен (преобразован в нормальный объект на карте)
		protected function createSurrogate(itemType:ItemType):void
		{
			var surrogate:MapSurrogateView = new MapSurrogateView(itemType);
			this.addChild(surrogate);
			startMovingObject(surrogate);
		}
		
		// удаление псевдообъекта с карты
		protected function dropCurrentObject():void
		{
			if (!_currentMapObject) return;
			if (_currentMapObject is MapSurrogateView) {
				_currentMapObject.dispose();
				if ((_currentMapObject as DisplayObject).parent)
					(_currentMapObject as DisplayObject).parent.removeChild(_currentMapObject as DisplayObject);
			} else {
				var mapObjectView:MapObjectView = _currentMapObject as MapObjectView;
				mapObjectView.update();
			}
			_currentMapObject = null;
		}
		
		// постройка объекта на карте
		protected function putCurrentObject():Boolean
		{
			var mapObjectView:MapObjectView = _currentMapObject as MapObjectView;
			var result:Boolean = _controller.tryMoveItem(mapObjectView.itemID, mapObjectView.xpos, mapObjectView.ypos, moveHandler);
			return result;
		}
		
		// обработчик события клика по сцене
		protected function clickHandler(event:MouseEvent):void
		{
			trace("clicked in state", _currentState);
			if (_currentState == NORMAL_STATE)
				return;
			if (_currentState == PLACING_STATE) {
				var itemType:String = _currentMapObject.itemType.name;
				var itemID:String = _controller.tryPlaceItem(itemType, _currentMapObject.xpos, _currentMapObject.ypos, placeHandler);
				var result:Boolean = _controller.getItem(null, itemID, place);
				return;
			} else if (_currentState == MOVING_STATE) {
				if (_moving) {
					itemID = _currentMapObject.itemID;
					var xpos:int = _currentMapObject.xpos;
					var ypos:int = _currentMapObject.ypos;
					result = _controller.tryMoveItem(itemID, xpos, ypos, placeHandler);
					if (result) stopMovingObject(result);
					else _currentMapObject.setPosition(xpos, ypos);
					return;
				} else {
					var cell:Point = tilesLayer.getTargetCell(tilesLayer.mouseX, tilesLayer.mouseY);
					var mapObject:Item = tilesLayer.getObject(cell.x, cell.y);
					if (mapObject) {
						var mapObjectView:MapObjectView = _items[mapObject.id] as MapObjectView;
						startMovingObject(mapObjectView);
					}
				}
			}
			return;
		}
		
		// установка нового объекта карты
		public function place(mapObject:Item):void
		{
			var mapObjectView:MapObjectView = new MapObjectView(mapObject);
			addItemHander(mapObjectView);
			setState(NORMAL_STATE);
		}
		
		// добавление визуального объекта карты
		protected function addItemHander(mapObjectView:MapObjectView):void
		{
			mapObjectView.addEventListener(MapObjectView.UPGRADE, upgradeMapObjectHandler);
			mapObjectView.addEventListener(MapObjectView.COLLECT, collectMapObjectHandler);
			mapObjectView.addEventListener(MapObjectView.MOVING_CHANGE, movingChangeMapObjectHandler);
			
			// TODO(Alex Sarapulov): Вместо обычной сортировки или вставки, нужно использовать класс быстрой вставки DoubleIndexInserter
			
			insertInSortedList(mapObjectView);
			_items[mapObjectView.itemID] = mapObjectView;
		}
		
		// удаление визуального объекта карты
		protected function dropItemHander(itemID:String):void
		{
			var mapObjectView:MapObjectView = _items[itemID];
			if (!mapObjectView) return;
			mapObjectView.removeEventListener(MapObjectView.UPGRADE, upgradeMapObjectHandler);
			mapObjectView.removeEventListener(MapObjectView.COLLECT, collectMapObjectHandler);
			mapObjectView.removeEventListener(MapObjectView.MOVING_CHANGE, movingChangeMapObjectHandler);
			if (mapObjectView.parent)
				mapObjectView.parent.removeChild(mapObjectView);
			//var index:int = _indexInserter.remove(mapObjectView);
			delete _items[itemID];
		}
		
		// сортировка объектов карты по Y-оси
		protected function insertInSortedList(mapObjectView:MapObjectView):void
		{
			var len:int = itemsLayer.numChildren;
			var i:int = 0;
			for (i; i < len; i++) {
				var object:MapObjectView = itemsLayer.getChildAt(i) as MapObjectView;
				if (object.y >= mapObjectView.y)
					break;
			}
			itemsLayer.addChildAt(mapObjectView, i);
		}
		
		// обработчик события обновления уровня объекта
		public function upgradeMapObjectHandler(event:Event = null):void
		{
			var itemIDs:Array;
			if (event && (event.currentTarget is MapObjectView)) {
				itemIDs = [(event.currentTarget as MapObjectView).itemID];
			}
			var result:Array = _controller.tryUpgradeItems(itemIDs, upgradeHandler);
			return;
		}
		
		// обработчик события сбора объекта
		protected function collectMapObjectHandler(event:Event):void
		{
			var mapObjectView:MapObjectView = event.currentTarget as MapObjectView;
			var result:Boolean = _controller.tryCollectItem(mapObjectView.itemID, collectHandler);
			if (result) dropItemHander(mapObjectView.itemID);
		}
		
		// обработчик события перемещения объекта на карте
		protected function movingChangeMapObjectHandler(event:Event):void
		{
			if (_moving) return;
			var mapObjectView:MapObjectView = event.currentTarget as MapObjectView;
			if (!mapObjectView.moving)
				return;
			var mapObject:Item = mapObjectView.mapObject;
			_currentUser.clearItemPosition(mapObject);
			_currentMapObject = mapObjectView;
			mapObjectView.mouseChildren = false; 
			startMovingObject(mapObjectView);
		}
		
		// начать перемещать объект карты
		protected function startMovingObject(object:IMapObjectView):void
		{
			_moving = true;
			_currentMapObject = object;
			if ((_currentMapObject as DisplayObject).parent == itemsLayer) {
				itemsLayer.removeChild(_currentMapObject as DisplayObject);
				itemsLayer.addChild(_currentMapObject as DisplayObject);
			}
			tilesLayer.setCheckingObject(object);
		}
		
		// закончить перемещать объект карты
		protected function stopMovingObject(save:Boolean = false):void
		{
			if (!save) {
				dropCurrentObject();
			} else if (putCurrentObject()) {
				var mapObjectView:MapObjectView = _currentMapObject as MapObjectView;
				if (mapObjectView.parent)
					mapObjectView.parent.removeChild(mapObjectView);
				insertInSortedList(mapObjectView);
			}
			tilesLayer.clearCheckingObject();
			_moving = false;
		}
		
		
		
		
		// обработчик серверного ответа на установку объекта
		public function placeHandler(data:*):void
		{
			trace("from server " + data);
		}
		
		public function upgradeHandler(data:*):void
		{
			trace("from server " + data);
		}
		
		public function collectHandler(data:*):void
		{
			trace("from server " + data);
		}
		
		public function moveHandler(data:*):void
		{
			trace("from server " + data);
		}
		
		// -- включение и выключение карты
		
		// обработчик события добавление карты на сцену
		protected function addedToStageHandler(event:Event = null):void
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			
			resize(stage.stageWidth, stage.stageHeight);
			
			_target.x = tilesLayer.xpos + tilesLayer.normalWidth / 2;
			_target.y = tilesLayer.ypos + tilesLayer.normalHeight / 2;
			center();
			
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
		
		// -- перемещение карты с помощью мыши
		
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
		
		// -- позиционирование камеры
		
		// центрирование положения карты вокруг фокусной точки
		public function center():void
		{
			var _x:Number = _target.x + _stageWidth / 2 - backgroundLayer.width;
			var _y:Number = _target.y + _stageHeight / 2 - backgroundLayer.height;
			moveTo(_x, _y, false);
		}
		
		// перемещение карты на заданную позицию
		protected function moveTo(xpos:Number, ypos:Number, updateTargetPosition:Boolean = true):void
		{
			if (xpos > 0) xpos = 0;
			if (ypos > 0) ypos = 0;
			if (xpos < _stageWidth - backgroundLayer.width)
				xpos = _stageWidth - backgroundLayer.width;
			if (ypos < _stageHeight - backgroundLayer.height)
				ypos = _stageHeight - backgroundLayer.height;
			if (updateTargetPosition) {
				_target.x = xpos + backgroundLayer.width - _stageWidth / 2;
				_target.y = ypos + backgroundLayer.height - _stageHeight / 2;
			}
			x = xpos;
			y = ypos;
		}
		
		// обработчик изменения размера контейнера
		public function resize(width:Number, height:Number):void
		{
			_stageWidth = stage.stageWidth;
			_stageHeight = stage.stageHeight;
			
			// обновляем фон
			var backWidth:Number = Math.max(tilesLayer.normalWidth + 2 * Isometric.PADDING_X, _stageWidth);
			var backHeight:Number = Math.max(tilesLayer.normalHeight + 2 * Isometric.PADDING_Y, _stageHeight);
			backgroundLayer.setSize(backWidth, backHeight);
			
			// фокусируем на фокусной точке карты
			center(); 
		}
	}
}