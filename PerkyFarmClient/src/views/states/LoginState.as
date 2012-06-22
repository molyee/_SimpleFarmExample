package views.states
{
	import controllers.ClientConnectionController;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import views.panels.LoginForm;

	[Event(name="complete", type="flash.events.Event")]
	public class LoginState extends BaseState
	{
		// триггер запуска
		private var _started:Boolean;
		
		// форма авторизации
		private var _loginForm:LoginForm;
		
		// -- конструктор
		public function LoginState(stateID:String, holder:Sprite, connection:ClientConnectionController)
		{
			_loginForm = new LoginForm(connection);
			
			var inners:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			inners.push(_loginForm);
			
			super(stateID, holder, inners);
		}
		
		// запуск активности состояния
		override public function start():void
		{
			if (_started) return;
			_started = true;
			_loginForm.addEventListener(Event.COMPLETE, loginCompleteHandler);
			_loginForm.init();
			trace(_stateID + " started");
		}
		
		// остановка активности состояния
		override public function stop():void
		{
			if (!_started) return;
			_started = false;
			_loginForm.removeEventListener(Event.COMPLETE, loginCompleteHandler);
			_loginForm.clear();
			trace(_stateID + " stopped");
		}
		
		// обработчик завершения авторизации
		private function loginCompleteHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			dispatchEvent(new Event(Event.COMPLETE)); // сообщаем о завершении работы
		}
		
		// обработчик изменения внешнего контейнера (или stage), для обновления позиции и размера вхождения
		override public function resize(width:Number, height:Number):void
		{
			_loginForm.resize(width, height);
		}
	}
}