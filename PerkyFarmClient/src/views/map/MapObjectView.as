package views.map 
{
	import display.BitmapDataLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import math.Isometric;
	import models.Item;
	import models.ItemType;
	import models.SkinData;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class MapObjectView extends Sprite implements IMapObjectView
	{
		// ссылка на карту
		public static var MAP_VIEW:MapView;
		
		// названия событий визуального объекта
		public static const MOVING_CHANGE:String = "movingChange";
		public static const COLLECT:String = "collect";
		public static const UPGRADE:String = "upgrade";
		
		// фильтры наведения мыши
		protected static const ACTIVE_FILTERS:Array = [new GlowFilter(0xffffff, 1, 5, 5, 2, 2)];
		
		// ссылка на объект карты
		protected var _mapObject:Item;
		public function get mapObject():Item { return _mapObject; }
		
		// размер объекта в ячейках
		public function get w():int { return _mapObject.size[0]; }
		public function get h():int { return _mapObject.size[1]; }
		
		// позиция объекта в сетке ячеек
		protected var _xpos:int;
		public function get xpos():int { return _xpos; }
		protected var _ypos:int;
		public function get ypos():int { return _ypos; }
		
		// триггер доступности объекта карты
		public function get enabled():Boolean { return _mapObject.enabled; }
		
		// текущий уровень визуального объекта (идентификатор скина)
		protected var _level:uint; 
		
		protected var _skins:Object; // имеющиеся скины для объекта
		protected var _currentSkin:Bitmap; // текущий скин
		
		// состояние перемещения объекта
		protected var _moving:Boolean;
		public function get moving():Boolean { return _moving; }
		
		// получение идентификатора объекта
		public function get itemID():String { return _mapObject.id; }
		
		public function get itemType():ItemType { return ItemType.getItemTypeData(_mapObject.item_type); }
		
		// -- конструктор
		public function MapObjectView(mapObject:Item) 
		{
			_skins = { };
			_mapObject = mapObject;
			
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
			
			_mapObject.addEventListener(Event.CHANGE, update);
			update();
		}
		
		// обработчик события клика мыши по визуальному объекту
		protected function clickHandler(event:MouseEvent):void
		{
			if (MAP_VIEW.currentState == MapView.MOVING_STATE) {
				changeMoving(); // запускаем смену режима перемещения
			} else if (_mapObject.level == _mapObject.maxLevel) {
				collectObject(); // запускаем сбор объекта
			} else {
				upgrade(); // запускаем инкремент уровня
			}
		}
		
		// запуск изменения режима перемещения объекта
		protected function changeMoving():void
		{
			_moving = !_moving;
			dispatchEvent(new Event(MOVING_CHANGE));
		}
		
		// запуск сбора объекта
		protected function collectObject():void
		{
			dispatchEvent(new Event(COLLECT));
		}
		
		// запуск инкремента уровня
		protected function upgrade():void
		{
			dispatchEvent(new Event(UPGRADE));
		}
		
		// обработчик события наведения курсора мыши на объект
		protected function mouseOverHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
			this.filters = ACTIVE_FILTERS;
		}
		
		// обработчик события уведения курсора мыши с объекта
		protected function mouseOutHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
			this.filters = null;
		}
		
		// обновить данные визуализации
		public function update(event:Event = null):void
		{
			if (mapObject.x != _xpos || mapObject.y != _ypos)
				setPosition(mapObject.x, mapObject.y);
			if (_mapObject.level != _level)
				setLevel(_mapObject.level);
		}
		
		// установка позиции визуального объекта в координатах ячеек
		public function setPosition(xpos:int, ypos:int):void
		{
			_xpos = xpos;
			_ypos = ypos;
			var pos:Point = Isometric.normalToIsometric(_xpos, _ypos);
			x = pos.x;
			y = pos.y;
		}
		
		// установка уровня объекта (смена скина)
		protected function setLevel(level:uint):void
		{
			_level = level;
			setSkin(_level);
		}
		
		// установка скина визуального объекта
		protected function setSkin(level:uint):void
		{
			var skin:Bitmap = _skins[level];
			var itemType:ItemType = ItemType.getItemTypeData(_mapObject.item_type);
			var skinData:SkinData = itemType.getImageData(level);
			if (!skin) {
				var loader:BitmapDataLoader = new BitmapDataLoader(skinData.url,
				function(data:BitmapData):void {
					_skins[level] = new Bitmap(data);
					if (_mapObject.level == level)
						setSkin(level);
				});
				return;
			}
			skin.x = skinData.offsetX - skin.width /2;
			skin.y = skinData.offsetY - skin.height / 2;
			if (_currentSkin) {
				if (_currentSkin.parent)
					_currentSkin.parent.removeChild(_currentSkin);
			}
			_currentSkin = skin;
			this.addChild(skin);
		}
		
		// -- финализатор
		public function dispose():void
		{
			this.removeEventListener(MouseEvent.CLICK, clickHandler);
			this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
			_mapObject.removeEventListener(Event.CHANGE, update);
			_mapObject = null;
			_skins = null;
			_currentSkin = null;
		}
		
	}

}