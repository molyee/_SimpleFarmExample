package display.controls.buttons
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	/**
	 * Базовый класс кнопки, в которой существует один отображаемый объект
	 * и несколько настроек фильтрации для различных состояний кнопки (активна,
	 * отключена, нажата)
	 * ...
	 * @author Alex Sarapulov
	 */
	public class BaseButton extends Sprite
	{
		// -- константы состояний кнопки
		
		/** Константа, отражающая нормальное состояние кнопки */
		public static const NORMAL_STATE:String = "normalState";
		/** Константа, отражающая активное состояние кнопки (наведение курсора мыши) */
		public static const ACTIVE_STATE:String = "activeState";
		/** Константа, отражающая состояние нажатия на кнопку */
		public static const DOWN_STATE:String = "downState";
		/** Константа, отражающая отключенное состояние кнопки */
		public static const DISABLED_STATE:String = "disabledState";
		
		/**
		 * Список данных о состояниях кнопки
		 * 
		 */
		protected var _states:Object;
		
		// поле доступности действий с кнопкой
		protected var _enabled:Boolean = true;
		/**
		 * Триггер, обозначающий включена ли кнопка (true), или же любые действия с
		 * кнопкой отключены (false)
		 * 
		 */
		public function get enabled():Boolean { return _enabled; }
		/**
		 * Установка триггера включения/выключения кнопки
		 * @private
		 */
		public function set enabled(value:Boolean):void {
			if (_enabled == value) return;
			_enabled = value;
			if (_isOver)
				Mouse.cursor = "auto";
			updateState();
		}
		
		protected var _id:String; // идентификатор кнопки
		/**
		 * Идентификатор или имя кнопки (не обязательно должно быть уникальным, но должно 
		 * определять объект (только чтение)
		 * 
		 */
		public function get id():String { return _id; }
		
		/**
		 * Триггер активного состояния кнопки (курсор мыши на кнопке)
		 * @private
		 */
		protected var _isOver:Boolean = false;
		
		/**
		 * Триггер состояния нажатия на кнопки (клавиша мыши опущена)
		 * @private
		 */
		protected var _isDown:Boolean = false; // триггер нажатия кнопки
		
		protected var _handler:Function; // обработчик клика по включенной кнопке
		/**
		 * Установка обработчика нажатия на включенную кнопки (только запись)
		 * 
		 */
		public function set handler(value:Function):void { _handler = value; }
		
		/**
		 * Визуальный объект кнопки, на который в различных состояниях накладываются фильтры
		 * @private
		 */
		protected var _normalState:DisplayObject;
		
		/**
		 * Конструктор кнопки
		 * 
		 * @param	id Идентификатор (наименование) кнопки
		 * @param	normalState Визуальный объект кнопки
		 * @param	disabledState Массив фильтров в отключенном состоянии
		 * @param	activeState Массив фильтров в активном состоянии (курсор мыши наведен на кнопку)
		 * @param	downState Массив фильтров в нажатом состоянии
		 * 
		 */
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
		
		/**
		 * Обновление визуального состояния кнопки на основе значений триггеров
		 * @private
		 */
		protected function updateState():void
		{
			if (!_enabled) // если отключена
				this.filters = _states[DISABLED_STATE] as Array;
			else if (_isDown) // если нажата
				this.filters = _states[DOWN_STATE] as Array;
			else if (_isOver) // если активна
				this.filters = _states[ACTIVE_STATE] as Array;
			else // если в состоянии простоя
				this.filters = null;
		}
		
		/**
		 * Обработчик опускания кнопки мыши вниз
		 * 
		 * @param	event Событие нажатия кнопки мыши
		 * @private
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			if (!_enabled) return;
			_isDown = true;
			updateState();
		}
		
		/**
		 * Обработчик поднятия кнопки мыши вверх
		 * 
		 * @param	event События отпускания кнопки мыши
		 * @private
		 */
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
		
		/**
		 * Обработчик наведения курсора мыши на кнопку
		 * 
		 * @param	event Событие наведения курсора
		 * @private
		 */
		protected function rollOverHandler(event:MouseEvent):void
		{
			if (!_enabled) return;
			Mouse.cursor = "button";
			_isOver = true;
			updateState();
		}
		
		/**
		 * Обработчик уведения курсора мыши с кнопки
		 * 
		 * @param	event Событие уведения курсора
		 * @private
		 */
		protected function rollOutHandler(event:MouseEvent):void
		{
			if (!_enabled) return;
			Mouse.cursor = "auto";
			_isOver = false;
			_isDown = false;
			updateState();
		}
		
		/**
		 * Обработчик добавления кнопки в дисплей-лист. Он же инициализирует
		 * начальное состояние кнопки и подписывает ее на события действий мыши
		 * 
		 * @param	event Событие добавление в дисплей-лист
		 * 
		 */
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
		
		/**
		 * Обработчик удаления кнопки из дисплей-листа. Он же сбрасывает фильтры, наложенные на
		 * визуализацию кнопки, а также отписывает ее от событий действий мыши
		 * 
		 * @param	event Событие удаления из дисплей-листа
		 * 
		 */
		protected function removedFromStageHandler(event:Event = null):void
		{
			this.filters = null;
			// удаление слушателей
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		/**
		 * Деструктор объекта кнопки
		 * 
		 */
		public function dispose():void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			if (stage) { // если кнопка отображается в дисплей-листе
				if (_isOver) {
					Mouse.cursor = "auto";
				}
				removedFromStageHandler();// отписываем от событий
				parent.removeChild(this);// удаляем из списка визуализации
			}
			for (var key:String in _states) { // очищаем данные о состояниях
				delete _states[key];
			}
			// обнуление прочих ссылочных данных
			filters = null;
			_states = null;
			_handler = null;
			_id = null;
		}
	}
}