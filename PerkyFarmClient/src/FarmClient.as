package
{
	import controllers.ClientConnectionController;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import views.states.IBaseState;
	
	import views.states.BaseState;
	import views.states.GameState;
	import views.states.LoginState;
	
	[SWF(width="1000", height="600")]
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class FarmClient extends Sprite
	{
		// список состояний приложения (визуальные объекты сменяющие друг друга)
		private var _states:Object;
		// текущее состояние приложения
		private var _currentState:IBaseState;
		// контроллер соединения с сервером
		private var _connection:ClientConnectionController;
		
		// -- конструктор
		public function FarmClient()
		{
			super();
			
			_connection = new ClientConnectionController();
			_connection.connect(Settings.SERVER_HOST, Settings.SERVER_PORT);
			
			_states = {
				"loginState": new LoginState("loginState", this, _connection),
				"gameState": new GameState("gameState", this, _connection)
			}
			for each (var state:IBaseState in _states) {
				state.addEventListener(Event.COMPLETE, stateCompleteHandler);
			}
			
			if (stage) init();
			else this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// инициализация сцены и установка состояния
		private function init(event:Event = null):void
		{
			if (this.hasEventListener(Event.ADDED_TO_STAGE))
				this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, stageResizeHandler);
			stage.addEventListener(Event.FULLSCREEN, stageFullscreenHandler);
			
			setState("loginState");
		}
		
		// обработчик события завершения состояния
		private function stateCompleteHandler(event:Event):void
		{
			var state:IBaseState = event.currentTarget as IBaseState;
			switch (state.stateID) {
				case "loginState":
					setState("gameState");
					break;
				case "gameState":
					setState("loginState");
					break;
			}
		}
		
		// получение объекта состояния
		private function getState(stateID:String):IBaseState
		{
			return _states[stateID] as IBaseState;
		}
		
		// установка состояния
		public function setState(stateID:String):void
		{
			var state:IBaseState = getState(stateID);
			if (state == _currentState) return;
			if (_currentState != null) {
				_currentState.setSelection(false);
				_currentState.stop();
			}
			_currentState = state;
			_currentState.setSelection(true);
			stageResizeHandler();
			_currentState.start();
		}
		
		// обработчик событий перехода в полноэкранный режим и обратно в оконный
		private function stageFullscreenHandler(event:Event):void
		{
			stageResizeHandler(event);
		}
		
		// обработчик события изменения размера сцены (окна)
		private function stageResizeHandler(event:Event = null):void
		{
			if (!_currentState || !stage) return;
			_currentState.resize(stage.stageWidth, stage.stageHeight);
		}
	}
}