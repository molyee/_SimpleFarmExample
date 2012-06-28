package views.panels 
{
	import display.utils.BitmapCache;
	import events.ObjectEvent;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import models.ItemType;
	import views.controls.buttons.ItemTypeIcon;
	
	/**
	 * Класс панели выбора объекта для постройки (установки на карте)
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ItemSelectPanel extends Sprite 
	{
		// -- константы
		
		/**
		 * Ширина панели
		 * 
		 */
		public static const PANEL_WIDTH:int = 385;
		
		/**
		 * Высота панели в открытой форме
		 * @private
		 */
		public static const PANEL_HEIGHT:int = 100;
		
		/**
		 * Высота парели в закрытой форме
		 * @private
		 */
		protected static const PANEL_HIDDEN_DELTA:int = 90;
		
		/**
		 * Скорость анимации при сворачивании/разворачивании панели
		 * @private
		 */
		protected static const ANIM_SPEED:Number = 0.85;
		
		/**
		 * Отступ внутренних элементов от левого края панели
		 * @private
		 */
		protected static const PADDING_X:int = 15;
		
		/**
		 * Отступ внутренних элементов от верхнего края панели
		 * @private
		 */
		protected static const PADDING_Y:int = 15;
		
		/**
		 * Дистанция между элементами панели
		 * @private
		 */
		protected static const CELL_SPACING:int = 10;
		
		/**
		 * Родительский контейнер
		 * @private
		 */
		protected var _holder:Sprite;
		
		/**
		 * Состояние включенной анимации (true)
		 * @private
		 */
		protected var _animated:Boolean;
		
		protected var _enabled:Boolean = true;
		/**
		 * Триггер доступности действий (выбора элементов
		 * 
		 */
		public function get enabled():Boolean { return _enabled; }
		
		/**
		 * Конструктор класса панели выбора элементов
		 * 
		 */
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
		
		/**
		 * Обработчик добавления панели на сцену
		 * 
		 * @param	event Событие добавления панели в дисплей лист
		 * @private
		 */
		protected function init(event:Event = null):void
		{
			if (event)
				(event.currentTarget as IEventDispatcher).removeEventListener(Event.ADDED_TO_STAGE, init);
			resize(stage.stageWidth, stage.stageHeight);
		}
		
		/**
		 * Обновление списка элементов в панели
		 * 
		 * @param	itemTypesData Данные о типах объектов карты
		 * 
		 */
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
		
		/**
		 * Обработчик клика по элементу в списке панели
		 * 
		 * @param	event Событие клика по элементу в списке элементов панели
		 * 
		 */
		protected function clickItemHandler(event:MouseEvent):void
		{
			var icon:ItemTypeIcon = event.currentTarget as ItemTypeIcon;
			select(icon.itemType);
		}
		
		/**
		 * Показать панель
		 * 
		 */
		public function show():void
		{
			if (_enabled) return;
			_enabled = true;
			if (_animated) return;
			_animated = true;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Скрыть панель
		 * 
		 */
		public function hide():void
		{
			if (!_enabled) return;
			_enabled = false;
			if (_animated) return;
			_animated = true;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Обработчик событий входа в кадр для создания анимации движения
		 * 
		 * @param	event Событие входа в кадр
		 * 
		 */
		protected function enterFrameHandler(event:Event):void
		{
			var targetY:Number = _enabled ? 0 : PANEL_HIDDEN_DELTA 
			_holder.y = targetY - (targetY - _holder.y) * ANIM_SPEED;
			if (Math.abs(targetY - _holder.y) > 0.1) return;
			_holder.y = targetY;
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_animated = false;
		}
		
		/**
		 * Выбор объекта в списке элементов
		 * 
		 * @param	itemType Данные о типе объекта
		 * 
		 */
		public function select(itemType:ItemType):void
		{
			trace(itemType.name + " selected");
			dispatchEvent(new ObjectEvent(Event.SELECT, itemType));
		}
		
		/**
		 * Обработчик изменения размеров контейнера
		 * 
		 * @param	width Ширина родительского контейнера (пиксели)
		 * @param	height Высота родительского контейнера (пиксели)
		 * 
		 */
		public function resize(width:Number, height:Number):void
		{
			this.x = (width - this.width) / 2;
			this.y = height - PANEL_HEIGHT;
		}
	}

}