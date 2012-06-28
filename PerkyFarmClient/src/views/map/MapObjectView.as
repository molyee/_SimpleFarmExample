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
	 * Класс визуального объекта карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class MapObjectView extends Sprite implements IMapObjectView
	{
		/**
		 * Ссылка на вью игровой карты
		 * 
		 */
		public static var MAP_VIEW:MapView;
		
		// -- константы событий визуального объекта
		/** Константа события перемещения объекта в новую позицию */
		public static const MOVING_CHANGE:String = "movingChange";
		/** Константа события сбора готового объекта с карты */
		public static const COLLECT:String = "collect";
		/** Константа события изменения уровня объекта карты */
		public static const UPGRADE:String = "upgrade";
		
		/**
		 * Фильтры применяемые к визуальному объекту при наведении курсора мыши
		 * 
		 */
		protected static const ACTIVE_FILTERS:Array = [new GlowFilter(0xffffff, 1, 5, 5, 2, 2)];
		
		protected var _mapObject:Item;
		/**
		 * Ссылка на модель объекта карты
		 * 
		 */
		public function get mapObject():Item { return _mapObject; }
		
		// -- размер объекта в ячейках
		
		/**
		 * Размер объекта в ячейках (кол-во колонок X-координата)
		 * 
		 */
		public function get w():int { return _mapObject.size[0]; }
		/**
		 * Размер объекта в ячейках (кол-во строк Y-координата)
		 * 
		 */
		public function get h():int { return _mapObject.size[1]; }
		
		// -- позиция объекта в сетке ячеек
		
		protected var _xpos:int;
		/**
		 * X-позиция привязки объекта к ячейки
		 * 
		 */
		public function get xpos():int { return _xpos; }
		
		protected var _ypos:int;
		/**
		 * Y-позиция привязки объекта к ячейки
		 * 
		 */
		public function get ypos():int { return _ypos; }
		
		
		/**
		 * Триггер доступности объекта карты
		 * 
		 */
		public function get enabled():Boolean { return _mapObject.enabled; }
		
		/**
		 * Текущий уровень визуального объекта (идентификатор скина)
		 * @private
		 */
		protected var _level:uint; 
		
		/**
		 * Имеющиеся скины для объекта
		 * @private
		 */
		protected var _skins:Object;
		
		/**
		 * Текущий скин
		 * @private
		 */
		protected var _currentSkin:Bitmap;
		
		protected var _moving:Boolean;
		/**
		 * Триггер состояния перемещения объекта, true - объект в данный момент перемещается и
		 * жестко не привязан к позиции модели
		 * 
		 */
		public function get moving():Boolean { return _moving; }
		
		/**
		 * Идентификатор объекта
		 * 
		 */
		public function get itemID():String { return _mapObject.id; }
		
		/**
		 * Тип модели объекта
		 * 
		 */
		public function get itemType():ItemType { return ItemType.getItemTypeData(_mapObject.item_type); }
		
		/**
		 * Конструктор визуализации модели объекта
		 * 
		 * @param	mapObject Привязываемая модель объекта карты
		 */
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
		
		/**
		 * Обработчик события клика мыши по визуальному объекту
		 * 
		 * @param	event Событие клика мыши
		 * @private
		 */
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
		
		/**
		 * Запуск изменения режима перемещения объекта
		 * 
		 */
		protected function changeMoving():void
		{
			_moving = !_moving;
			dispatchEvent(new Event(MOVING_CHANGE));
		}
		
		/**
		 * Запуск сбора объекта
		 * 
		 */
		protected function collectObject():void
		{
			dispatchEvent(new Event(COLLECT));
		}
		
		/**
		 * Запуск инкремента уровня
		 * 
		 */
		protected function upgrade():void
		{
			dispatchEvent(new Event(UPGRADE));
		}
		
		/**
		 * Обработчик события наведения курсора мыши на объект
		 * 
		 * @param	event Событие наведения курсора мыши на объект
		 * @private
		 */
		protected function mouseOverHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
			this.filters = ACTIVE_FILTERS;
		}
		
		/**
		 * Обработчик события уведения курсора мыши с объекта
		 * 
		 * @param	event Слюыьие уведения курсора мыши с объекта
		 * @private
		 */
		protected function mouseOutHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
			this.filters = null;
		}
		
		/**
		 * Обновление данных визуализации объекта
		 * 
		 * @param	event Событие, которое напрямую говорит визуализации о необходимости
		 * обновить внешний вид (например изменение уровня модели объекта)
		 */
		public function update(event:Event = null):void
		{
			if (mapObject.x != _xpos || mapObject.y != _ypos)
				setPosition(mapObject.x, mapObject.y);
			if (_mapObject.level != _level)
				setLevel(_mapObject.level);
		}
		
		/**
		 * Установка позиции визуального объекта в координатах ячеек
		 * 
		 * @param	xpos X-позиция ячейки, в которую следует установить объект
		 * @param	ypos Y-позиция ячейки, в которую следует установить объект
		 */
		public function setPosition(xpos:int, ypos:int):void
		{
			_xpos = xpos;
			_ypos = ypos;
			var pos:Point = Isometric.normalToIsometric(_xpos, _ypos);
			x = pos.x;
			y = pos.y;
		}
		
		/**
		 * Установка уровня объекта (смена скина)
		 * 
		 * @param	level Новый уровень объекта (id скина)
		 * 
		 */
		protected function setLevel(level:uint):void
		{
			_level = level;
			setSkin(_level);
		}
		
		/**
		 * Установка скина визуального объекта
		 * 
		 * @param	level Идентификатор скина, соответствующий уровню объекта
		 * @private
		 */
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
		
		/**
		 * Деструктор объекта визуализации
		 * 
		 */
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