package views.states
{
	import controllers.ClientConnectionController;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import views.panels.LoginForm;

	/**
	 * Класс состояния визуализации для неавторизованного пользователя
	 * 
	 */	
	[Event(name="complete", type="flash.events.Event")]
	public class LoginState extends BaseState
	{
		/**
		 * Триггер запуска
		 * 
		 */		
		private var _started:Boolean;
		
		/**
		 * Форма авторизации
		 * 
		 */		
		private var _loginForm:LoginForm;
		
		/**
		 * Конструктор состояния авторизации
		 * 
		 * @param stateID Идентификатор состояния
		 * @param holder Родительский контейнер
		 * @param controller Ссылка на контроллер клиента
		 * 
		 */		
		public function LoginState(stateID:String, holder:Sprite, controller:ClientConnectionController)
		{
			_loginForm = new LoginForm(controller);
			
			var inners:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			inners.push(_loginForm);
			
			super(stateID, holder, inners);
		}
		
		/**
		 * Запуск активности состояния
		 * 
		 */		
		override public function start():void
		{
			if (_started) return;
			_started = true;
			_loginForm.addEventListener(Event.COMPLETE, loginCompleteHandler);
			_loginForm.init();
			trace(_stateID + " started");
		}
		
		/**
		 * Остановка активности состояния
		 * 
		 */		
		override public function stop():void
		{
			if (!_started) return;
			_started = false;
			_loginForm.removeEventListener(Event.COMPLETE, loginCompleteHandler);
			_loginForm.clear();
			trace(_stateID + " stopped");
		}
		
		/**
		 * Обработчик завершения авторизации
		 * 
		 * @param event Событие завершения авторизации
		 * @private
		 */		
		private function loginCompleteHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			dispatchEvent(new Event(Event.COMPLETE)); // сообщаем о завершении работы
		}
		
		/**
		 * Обработчик изменения родительского контейнера (или stage),
		 * для обновления позиции и размера вхождения
		 * 
		 * @param width Ширина родительского контейнера
		 * @param height Высота родительского контейнера
		 * 
		 */		
		override public function resize(width:Number, height:Number):void
		{
			_loginForm.resize(width, height);
		}
	}
}