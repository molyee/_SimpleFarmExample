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
		
		protected var _currentState:String = "normal";
		/**
		 * Текущее состояние управления картой
		 * 
		 */
		public function get currentState():String { return _currentState; }
		
		
		// -- уровни
		
		/**
		 * Уровень фона
		 * 
		 */
		protected var backgroundLayer:BackgroundLayer;
		
		/**
		 * Уровень ячеек
		 * 
		 */
		protected var tilesLayer:TilesLayer;
		
		/**
		 * Уровень объектов
		 * 
		 */
		protected var itemsLayer:Sprite;
		
		
		// -- текущий размер сцены
		
		/**
		 * Ширина сцены
		 * @private
		 */
		protected var _stageWidth:Number;
		
		/**
		 * Высота сцены
		 * @private
		 */
		protected var _stageHeight:Number;
		
		// -- действия мыши
		
		/**
		 * Максимальное расстояние смещения карты (при перетаскивании) в пикселях,
		 * учитывающее отпускание кнопки мыши как клик
		 * @private
		 */
		protected static const DRAG_DEMPER:Number = 5;
		
		/**
		 * Предыдущее положение курсора мыши на сцене (при перемещении карты)
		 * @private
		 */
		protected var _lastPosition:Point;
		
		/**
		 * Позиция на сцене, на которой была нажата кнопка мыши
		 * @private
		 */
		protected var _downPosition:Point;
		
		/**
		 * Состояние перетаскивания карты
		 * @private
		 */
		protected var _dragging:Boolean = false;
		
		/**
		 * Триггер доступности функции перемещения карты с помощью мыши
		 * @private
		 */
		protected var _dragEnabled:Boolean = true;
		
		/**
		 * Точка на карте, на которую следует фокусироваться
		 * @private
		 */
		protected var _target:Point; 
		
		/**
		 * Активный объект (перемещаемый в данный момента)
		 * @private
		 */
		protected var _currentMapObject:IMapObjectView;
		
		/**
		 * Триггер запущенного перемещения объекта
		 * @private
		 */
		protected var _moving:Boolean;
		
		/**
		 * Список визуализаций объектов карты
		 * @private
		 */
		protected var _items:Object = { };
		
		/**
		 * Ссылка на контроллер
		 * @private
		 */
		protected var _controller:ClientConnectionController;
		
		protected var _currentUser:User;
		/**
		 * Текущий пользователь, чья карта отображается
		 * 
		 */
		public function get currentUser():User { return _currentUser; }
		/**
		 * Установка текущего пользователя, и обновление объектов карты
		 * @private
		 */
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
		
		// объект контролирующий быструю вставку в сортированный по Y-оси список объектов карты
		//protected var _indexInserter:DoubleIndexInserter;
		
		
		/**
		 * Конструктор класса карты
		 * 
		 * @param	controller Ссылка на контроллер клиента
		 * @param	size Размер карты в ячейках по одной из сторон сетки
		 * 
		 */
		public function MapView(controller:ClientConnectionController, size:int)
		{
			super();
			
			MapObjectView.MAP_VIEW = this;
			
			//_indexInserter = new DoubleIndexInserter(Isometric.PADDING_Y, Isometric.MAP_HEIGHT + 2*Isometric.PADDING_Y, "y", 15, DoubleIndexInserter.LINEAR);
			
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
		
		/**
		 * Обновление текстуры фона
		 * 
		 * @param	texture Растровые данные текстуры
		 * 
		 */
		public function setBackgroundTexture(texture:BitmapData):void
		{
			backgroundLayer.setTexture(texture);
		}
		
		/**
		 * Установка состояния (строительсто или норма)
		 * 
		 * @param	state Идентификатор (наименование) состояния
		 * @param	data Данные передаваемые создателю суррогата визуального объекта
		 * 
		 */
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
		
		/**
		 * Создание псевдообъекта, который может быть построен (преобразован в нормальный объект на карте)
		 * 
		 * @param	itemType Данные типа объекта карты
		 * @private
		 */
		protected function createSurrogate(itemType:ItemType):void
		{
			var surrogate:MapSurrogateView = new MapSurrogateView(itemType);
			this.addChild(surrogate);
			startMovingObject(surrogate);
		}
		
		/**
		 * Удаление псевдообъекта с карты
		 * @private
		 */
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
		
		/**
		 * Постройка объекта на карте
		 * 
		 * @return Предварительный результат постройки
		 * @private
		 */
		protected function putCurrentObject():Boolean
		{
			var mapObjectView:MapObjectView = _currentMapObject as MapObjectView;
			var result:Boolean = _controller.tryMoveItem(mapObjectView.itemID, mapObjectView.xpos, mapObjectView.ypos, moveHandler);
			return result;
		}
		
		/**
		 * Обработчик события клика по сцене
		 * 
		 * @param	event Событие клика мыши по сцене
		 * @private
		 */
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
		
		/**
		 * Установка нового объекта карты
		 * 
		 * @param	mapObject Модель объекта карты
		 * 
		 */
		public function place(mapObject:Item):void
		{
			var mapObjectView:MapObjectView = new MapObjectView(mapObject);
			addItemHander(mapObjectView);
			setState(NORMAL_STATE);
		}
		
		/**
		 * Добавление визуального объекта карты
		 * 
		 * @param	mapObjectView Визуализация объекта карты
		 * @private
		 */
		protected function addItemHander(mapObjectView:MapObjectView):void
		{
			mapObjectView.addEventListener(MapObjectView.UPGRADE, upgradeMapObjectHandler);
			mapObjectView.addEventListener(MapObjectView.COLLECT, collectMapObjectHandler);
			mapObjectView.addEventListener(MapObjectView.MOVING_CHANGE, movingChangeMapObjectHandler);
			
			// TODO(Alex Sarapulov): Вместо обычной сортировки или вставки, нужно использовать класс быстрой вставки DoubleIndexInserter
			
			insertInSortedList(mapObjectView);
			_items[mapObjectView.itemID] = mapObjectView;
		}
		
		/**
		 * Удаление визуального объекта карты
		 * 
		 * @param	itemID Идентификатор удаленного с карты объекта)
		 * @private
		 */
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
		
		/**
		 * Вставка объектов карты по Y-оси в сортированный список отображения объектов
		 * 
		 * @param	mapObjectView Визуализация объекта карты
		 * 
		 */
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
		
		/**
		 * Обработчик события обновления уровня объекта
		 * 
		 * @param	event Событие, уведомляющее о требовании запуска повышения уровня объекта,
		 * генерируется при клике на здание
		 * @private
		 */
		public function upgradeMapObjectHandler(event:Event = null):void
		{
			var itemIDs:Array;
			if (event && (event.currentTarget is MapObjectView)) {
				itemIDs = [(event.currentTarget as MapObjectView).itemID];
			}
			var result:Array = _controller.tryUpgradeItems(itemIDs, upgradeHandler);
			return;
		}
		
		/**
		 * Обработчик события сбора объекта
		 * 
		 * @param	event Событие, уведомляющее о требовании запуска сбора объекта с карты
		 * @private
		 */
		protected function collectMapObjectHandler(event:Event):void
		{
			var mapObjectView:MapObjectView = event.currentTarget as MapObjectView;
			var result:Boolean = _controller.tryCollectItem(mapObjectView.itemID, collectHandler);
			if (result) dropItemHander(mapObjectView.itemID);
		}
		
		/**
		 * Обработчик события перемещения объекта на карте
		 * 
		 * @param	event Событие, уведомляющее о требовании запуска начала перемещения объекта с карты
		 * @private
		 */
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
		
		// 
		/**
		 * Старт процесса перемещения объекта карты
		 * 
		 * @param	object Визуализация объекта карты или суррогат объекта карты, который требуется перемещать
		 * @private
		 */
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
		
		/**
		 * Завершение процесса перемещения объекта карты
		 * 
		 * @param	save Триггер говорит о том, следует ли сохранить позицию объекта
		 * @private
		 */
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
		
		// -- обработчики ответов сервера на действия клиента
		
		/**
		 * Обработчик ответа сервера на установку объекта
		 * 
		 * @param	data Результат установки объекта
		 * @private
		 */
		protected function placeHandler(data:*):void
		{
			trace("from server " + data);
		}
		
		/**
		 * Обработчик ответа сервера на повышение уровня объекта
		 * 
		 * @param	data Результат апгрейда объекта
		 * @private
		 */
		protected function upgradeHandler(data:*):void
		{
			trace("from server " + data);
		}
		
		/**
		 * Обработчик ответа сервера на сбор готового объекта
		 * 
		 * @param	data Результат сбора объекта
		 * @private
		 */
		protected function collectHandler(data:*):void
		{
			trace("from server " + data);
		}
		
		/**
		 * Обработчик ответа сервера на установку объекта
		 * 
		 * @param	data Результат установки объекта
		 * @private
		 */
		protected function moveHandler(data:*):void
		{
			trace("from server " + data);
		}
		
		// -- включение и выключение карты
		
		/**
		 * Обработчик события добавление карты на сцену
		 * 
		 * @param	event Событие, уведомляющее о добавлении карты на сцену
		 * @private
		 */
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
		
		/**
		 * Обработчик события удаления карты со сцены
		 * 
		 * @param	event Событие, уведомляющее об удалении карты со сцены
		 * @private
		 */
		protected function removedFromStage(event:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			this.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			backgroundLayer.hide();
		}
		
		// -- перемещение карты с помощью мыши
		
		/**
		 * Обработчик события опускания кнопки мыши
		 * 
		 * @param	event Событие зажатия кнопки мыши
		 * @private
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			_downPosition = new Point(event.stageX, event.stageY);
			_lastPosition = new Point(event.stageX, event.stageY);
			this.addEventListener(Event.ENTER_FRAME, draggingHandler);
		}
		
		/**
		 * Обработчик события поднятия кнопки мыши
		 * 
		 * @param	event Событие отжатия кнопки мыши
		 * @private
		 */
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
		
		/**
		 * Обработчик события перемещения мыши на сцене при зажатом состоянии кнопки мыши
		 * 
		 * @param	event Событие перемещения курсора мыши
		 * @private
		 */
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
		
		/**
		 * Центрирование положения карты вокруг фокусной точки
		 * 
		 */
		public function center():void
		{
			var _x:Number = _target.x + _stageWidth / 2 - backgroundLayer.width;
			var _y:Number = _target.y + _stageHeight / 2 - backgroundLayer.height;
			moveTo(_x, _y, false);
		}
		
		/**
		 * Перемещение карты на заданную позицию
		 * 
		 * @param	xpos Х-координата перемещения (пиксели)
		 * @param	ypos Y-координата перемещения (пиксели)
		 * @param	updateTargetPosition Триггер обновления точки фокуса карты
		 * @private
		 */
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
		
		/**
		 * Обработчик изменения размера контейнера
		 * 
		 * @param	width Ширина контейнера (сцены)
		 * @param	height Высота контейнера (сцены)
		 * 
		 */
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