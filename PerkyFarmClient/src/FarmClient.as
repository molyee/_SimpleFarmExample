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
	
	/**
	 * Основной класс запуска приложения обеспечивающий смену состояний
	 * приложения (страница авторизации, игровой процесс и т.д.), а также
	 * создающий соединение с сервером
	 * ...
	 * @author Alex Sarapulov
	 * 
	 */
	[SWF(width="1000", height="600")]
	public class FarmClient extends Sprite
	{
		/**
		 * список состояний приложения (визуальные объекты сменяющие друг друга) 
		 * @private
		 */
		private var _states:Object;
		/** 
		 * текущее состояние приложения
		 * @private
		 */
		private var _currentState:IBaseState;
		/** 
		 * контроллер соединения с сервером
		 * @private
		 */
		private var _connection:ClientConnectionController;
		
		/**
		 * Конструктор класса приложения
		 * - создает соединение с сервером,
		 * - инициализирует возможные состояния приложения
		 * - запускает инициализацию приложения
		 */
		public function FarmClient()
		{
			// создаем обобочку
			super();
			
			// создаем соединение с сервером
			_connection = new ClientConnectionController();
			_connection.connect(Settings.SERVER_HOST, Settings.SERVER_PORT);
			
			// инициализируем состояния
			_states = {
				"loginState": new LoginState("loginState", this, _connection),
				"gameState": new GameState("gameState", this, _connection)
			}
			for each (var state:IBaseState in _states) {
				state.addEventListener(Event.COMPLETE, stateCompleteHandler);
			}
			// переходим к точке входа сразу или асинхронно
			if (stage) init();
			else this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		 
		/**
		 * Инициализация сцены и установка состояния по умолчанию
		 * 
		 * @param event Событие готовности и доступности сцены приложения
		 * @private
		 */
		private function init(event:Event = null):void
		{
			if (this.hasEventListener(Event.ADDED_TO_STAGE))
				this.removeEventListener(Event.ADDED_TO_STAGE, init);
			// устанавливаем параметры сцены
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, stageResizeHandler);
			stage.addEventListener(Event.FULLSCREEN, stageFullscreenHandler);
			// устанавливаем состояние
			setState("loginState");
		}
		
		/**
		 * Обработчик события завершения состояния
		 * 
		 * @param event Событие, отправленное экземпляром класса состояния,
		 * объявляющее о том, что состояние завершило свою работы и необходимо
		 * перейти к следующему состоянию (какому - определяет текущий класс)
		 * @private
		 */
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
		
		/**
		 * Получение объекта состояния
		 * 
		 * @param stateID Идентификатор состояния (его наименование)
		 * @return Текущий экземпляр запрошенного состояния
		 * 
		 */
		private function getState(stateID:String):IBaseState
		{
			return _states[stateID] as IBaseState;
		}
		
		/**
		 * Активация состояния приложения (переход от старого состояния к новому)
		 * 
		 * @param stateID Идентификатор состояния (его наименование)
		 * 
		 */
		public function setState(stateID:String):void
		{
			trace("set state " + stateID);
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
		
		/**
		 * Ообработчик событий перехода в полноэкранный режим и обратно в оконный
		 * 
		 * @param event Стандартное событие перехода в полноэкранный режим
		 * 
		 */
		private function stageFullscreenHandler(event:Event):void
		{
			stageResizeHandler(event);
		}
		
		/**
		 * Обработчик события изменения размера сцены (окна)
		 * 
		 * @param event Событие уведомляющее о изменении размера сцены (окна)
		 * 
		 */
		private function stageResizeHandler(event:Event = null):void
		{
			if (!_currentState || !stage) return;
			_currentState.resize(stage.stageWidth, stage.stageHeight);
		}
	}
}