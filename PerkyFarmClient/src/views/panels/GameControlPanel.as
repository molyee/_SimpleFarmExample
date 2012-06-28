package views.panels
{
	import controllers.ClientConnectionController;
	import events.ObjectEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import models.Model;
	import views.controls.buttons.GLabeledButton;
	import views.map.MapView;
	
	/**
	 * Класс панели управления игровым процессом
	 * ...
	 * @author Alex Sarapulov
	 */
	public class GameControlPanel extends Sprite
	{
		/**
		 * Ссылка на контроллер
		 * @private
		 */
		private var _controller:ClientConnectionController;
		
		/**
		 * Ссылка на карту
		 * @private
		 */
		private var _mapView:MapView;
		
		/**
		 * Панель выбора елементов для постройки
		 * @private
		 */
		private var _itemSelector:ItemSelectPanel;
		
		/**
		 * Кнопка отмены действия
		 * @private
		 */
		private var _cancelButton:GLabeledButton;
		
		/**
		 * Кнопка начать/закончить перемещение объекта на карте
		 * @private
		 */
		private var _moveButton:GLabeledButton;
		
		/**
		 * Кнопка повышения уровня всех объектов на карте
		 * @private
		 */
		private var _upgradeButton:GLabeledButton;
		
		/**
		 * Конструктора класса панели управления
		 * 
		 * @param	controller Ссылка на контроллер клиента
		 * @param	mapView Ссылка на карту
		 * 
		 */
		public function GameControlPanel(controller:ClientConnectionController, mapView:MapView)
		{
			_mapView = mapView;
			_mapView.addEventListener(Event.CHANGE, mapStateChangeHandler);
			
			_itemSelector = new ItemSelectPanel();
			_itemSelector.addEventListener(Event.SELECT, selectItemTypeHandler);
			
			_cancelButton = new GLabeledButton("cancel", "Cancel", 100, 35);
			_cancelButton.addEventListener(MouseEvent.CLICK, cancelPlacingControl);
			this.addChild(_cancelButton);
			
			_moveButton = new GLabeledButton("move", "Move", 100, 35);
			_moveButton.addEventListener(MouseEvent.CLICK, moveItemControl);
			this.addChild(_moveButton);
			
			_upgradeButton = new GLabeledButton("upgrade", "Upgrade", 100, 30);
			_upgradeButton.addEventListener(MouseEvent.CLICK, upgradeControl);
			this.addChild(_upgradeButton);
			
			_controller = controller;
			if (Model.instance.inited)
				initHandler();
			else
				Model.instance.addEventListener(Event.INIT, initHandler);
			super();
			
			this.addChild(_itemSelector);
		}
		
		/**
		 * Инициализатор
		 * 
		 * @param	event Событие, уведомляющее об окончании инициализации модели
		 * @private
		 */
		protected function initHandler(event:Event = null):void
		{
			if (event)
				(event.currentTarget as IEventDispatcher).removeEventListener(Event.INIT, initHandler);
			_controller.getItemTypes(_itemSelector.updateItemTypes);
		}
		
		/**
		 * Обработчик события выбора объекта в списке
		 * 
		 * @param	event Событие, уведомляющее о выборе элемента на панели выбора
		 * и содержащее данные о шаблоне (типе) выбранного объекта карты
		 * @private
		 */
		protected function selectItemTypeHandler(event:ObjectEvent):void
		{
			setState(MapView.PLACING_STATE, event.data);
			event.dispose();
		}
		
		/**
		 * Обработчик нажатия кнопки отмены
		 * 
		 * @param	event Событие клика по кнопке отмены
		 * @private
		 */
		protected function cancelPlacingControl(event:Event):void
		{
			event.stopImmediatePropagation();
			setState(MapView.NORMAL_STATE);
		}
		
		/**
		 * Обработчик нажатия кнопки смены режима перемещения
		 * 
		 * @param	event Событие клика по кнопке перемещения
		 * @private
		 */
		protected function moveItemControl(event:Event):void
		{
			if (_mapView.currentState == MapView.MOVING_STATE) {
				cancelPlacingControl(event);
			} else {
				_mapView.setState(MapView.MOVING_STATE);
			}
		}
		
		/**
		 * Обработчик нажатия кнопки инкремента уровня всех объектов
		 * 
		 * @param	event Событие клика по кнопке апгрейда всех объектов на карте
		 * @private
		 */
		protected function upgradeControl(event:Event):void
		{
			_controller.tryUpgradeItems(null, function(data:*):void {
				trace(data);
			});
		}
		
		/**
		 * Обработчик события смены состояния управления картой
		 * 
		 * @param	event Событие, уведомляющее о смене состояния карты
		 * @private
		 */
		protected function mapStateChangeHandler(event:Event):void
		{
			var state:String = _mapView.currentState;
			if (state == MapView.PLACING_STATE || state == MapView.MOVING_STATE) {
				_itemSelector.hide();
				_upgradeButton.hide();
				if (state == MapView.PLACING_STATE) {
					_moveButton.hide();
					_cancelButton.show();
				} else {
					_moveButton.label = "Complete";
					_moveButton.show();
					_cancelButton.hide();
				}
			} else {
				_cancelButton.hide()
				_itemSelector.show();
				_upgradeButton.show();
				_moveButton.show();
				_moveButton.label = "Move";
			}
		}
		
		/**
		 * Установка состояния карты
		 * 
		 * @param	state Идентификатор (наименование) состояния
		 * @param	data Данные, передаваемые процессу смены состояния карты
		 * 
		 */
		public function setState(state:String, data:* = null):void
		{
			if (_mapView.currentState == state) return;
			_mapView.setState(state, data);
		}
		
		/**
		 * Обработчик изменения размера контейнера
		 * 
		 * @param	width Ширина родительского контейнера
		 * @param	height Высота родительского контейнера
		 * 
		 */
		public function resize(width:Number, height:Number):void
		{
			_itemSelector.resize(width, height);
			
			_cancelButton.x = (width - _cancelButton.width) / 2;
			_cancelButton.y = height - ItemSelectPanel.PANEL_HEIGHT + 10;
			
			_moveButton.x = 15;
			_moveButton.y = 20;
			
			_upgradeButton.x = 15;
			_upgradeButton.y = 70;
		}
	}
}