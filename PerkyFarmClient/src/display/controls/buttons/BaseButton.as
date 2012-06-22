package display.controls.buttons
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class BaseButton extends Sprite
	{
		// -- константы состояний кнопки
		public static const NORMAL_STATE:String = "normalState";
		public static const ACTIVE_STATE:String = "activeState";
		public static const DOWN_STATE:String = "downState";
		public static const DISABLED_STATE:String = "disabledState";
		
		// данные о состояниях кнопки
		protected var _states:Object;
		
		// триггер доступности
		protected var _enabled:Boolean = true;
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			if (_enabled == value) return;
			_enabled = value;
			if (_isOver)
				Mouse.cursor = "auto";
			updateState();
		}
		
		// идентификатор кнопки
		protected var _id:String;
		public function get id():String { return _id; }
		
		protected var _isOver:Boolean = false; // триггер нахождения мыши на кнопке
		protected var _isDown:Boolean = false; // триггер нажатия кнопки
		
		// обработчик клика по включенной кнопке (устанавливается извне)
		protected var _handler:Function;
		public function set handler(value:Function):void { _handler = value; }
		
		protected var _normalState:DisplayObject; // визуальный объект кнопки
		
		// -- конструктор (основное состояние дисплей объект, а остальные массивы фильтров)
		public function BaseButton(id:String, normalState:DisplayObject, disabledState:Array = null, activeState:Array = null, downState:Array = null)
		{
			super();
			if (!normalState) throw("Null normalState object received");
			_id = id;
			_normalState = normalState
			this.addChild(normalState);
			_states = {
				"activeState": activeState,
				"downState": downState,
				"disabledState": disabledState
			}
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		// обновление состояния
		protected function updateState():void
		{
			if (!_enabled)
				this.filters = _states[DISABLED_STATE] as Array;
			else if (_isDown)
				this.filters = _states[DOWN_STATE] as Array;
			else if (_isOver)
				this.filters = _states[ACTIVE_STATE] as Array;
			else
				this.filters = null;
		}
		
		// обработчик опускания кнопки мыши
		protected function mouseDownHandler(event:MouseEvent):void
		{
			if (!_enabled) return;
			_isDown = true;
			updateState();
		}
		
		// обработчик поднятия кнопки мыши
		protected function mouseUpHandler(event:MouseEvent):void
		{
			if (!_enabled) return;
			var complete:Boolean = _isDown;
			_isDown = false;
			updateState();
			if (complete && _handler != null) {
				Mouse.cursor = "auto";
				_handler(this);
			}
		}
		
		// обработчик наведения кнопки мыши
		protected function rollOverHandler(event:MouseEvent):void
		{
			if (!_enabled) return;
			Mouse.cursor = "button";
			_isOver = true;
			updateState();
		}
		
		// обработчик отведения кнопки мыши
		protected function rollOutHandler(event:MouseEvent):void
		{
			if (!_enabled) return;
			Mouse.cursor = "auto";
			_isOver = false;
			_isDown = false;
			updateState();
		}
		
		// обработчик добавления кнопки в дисплей-лист
		protected function addedToStageHandler(event:Event):void
		{
			// очистка прежнего состояния
			_isDown = false;
			_isOver = false;
			updateState();
			// установка слушателей
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		// обработчик удаления кнопки из дисплей-листа
		protected function removedFromStageHandler(event:Event = null):void
		{
			this.filters = null;
			// удаление слушателей
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		// -- финализатор
		public function dispose():void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			if (stage) {
				if (_isOver) {
					Mouse.cursor = "auto";
				}
				removedFromStageHandler();
				parent.removeChild(this);
			}
			for (var key:String in _states) {
				delete _states[key];
			}
			filters = null;
			_states = null;
			_handler = null;
			_id = null;
		}
	}
}