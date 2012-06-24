package views.panels
{
	import controllers.IConnectionController;
	import events.ObjectEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import models.Model;
	import views.controls.buttons.GLabeledButton;
	import views.map.MapView;
	
	public class GameControlPanel extends Sprite
	{
		private var _controller:IConnectionController;
		private var _mapView:MapView;
		private var _itemSelector:ItemSelectPanel;
		private var _cancelButton:GLabeledButton;
		private var _moveButton:GLabeledButton;
		private var _upgradeButton:GLabeledButton;
		
		public function GameControlPanel(controller:IConnectionController, mapView:MapView)
		{
			_mapView = mapView;
			_mapView.addEventListener(Event.CHANGE, mapStateChangeHandler);
			
			_itemSelector = new ItemSelectPanel();
			_itemSelector.addEventListener(Event.SELECT, selectItemTypeHandler);
			
			_cancelButton = new GLabeledButton("cancel", "Cancel", 100, 30);
			_cancelButton.addEventListener(MouseEvent.CLICK, cancelPlacingControl);
			this.addChild(_cancelButton);
			
			_moveButton = new GLabeledButton("move", "Move", 100, 30);
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
		
		// инициализатор
		protected function initHandler(event:Event = null):void
		{
			if (event)
				(event.currentTarget as IEventDispatcher).removeEventListener(Event.INIT, initHandler);
			_controller.getItemTypes(_itemSelector.updateItemTypes);
		}
		
		// обработчик события выбора объекта в списке
		protected function selectItemTypeHandler(event:ObjectEvent):void
		{
			setState(MapView.PLACING_STATE, event.data);
			event.dispose();
		}
		
		// обработчик нажатия кнопки отмены
		protected function cancelPlacingControl(event:Event):void
		{
			event.stopImmediatePropagation();
			setState(MapView.NORMAL_STATE);
		}
		
		// обработчик нажатия кнопки смена режима перемещения
		protected function moveItemControl(event:Event):void
		{
			if (_mapView.currentState == MapView.MOVING_STATE) {
				cancelPlacingControl(event);
			} else {
				_mapView.setState(MapView.MOVING_STATE);
			}
		}
		
		// обработчик нажатия кнопки инкремента уровня всех объектов
		protected function upgradeControl(event:Event):void
		{
			_controller.upgradeItems(null, null, function(data:*):void {
				trace(data);
			});
		}
		
		// обработчик события смены состояния управления картой
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
					_moveButton.label = "Cancel";
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
		
		// установка состояния карты
		public function setState(state:String, data:* = null):void
		{
			if (_mapView.currentState == state) return;
			_mapView.setState(state, data);
		}
		
		// обработчик изменения размера контейнера
		public function resize(width:Number, height:Number):void
		{
			_itemSelector.resize(width, height);
			
			_cancelButton.x = (width - _cancelButton.width) / 2;
			_cancelButton.y = height - ItemSelectPanel.PANEL_HEIGHT + 10;
			
			_moveButton.x = 15;
			_moveButton.y = 20;
			
			_upgradeButton.x = 15;
			_upgradeButton.y = 60;
		}
	}
}