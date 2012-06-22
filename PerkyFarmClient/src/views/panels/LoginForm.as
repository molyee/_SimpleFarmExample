package views.panels
{
	import controllers.ClientConnectionController;
	import display.controls.buttons.BaseButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import views.controls.buttons.GLabeledButton;
	
	[Event(name="complete", type="flash.events.Event")]
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class LoginForm extends Sprite
	{
		private static const PADDING_X:Number = 10;
		private static const PADDING_Y:Number = 10;
		private static const SELL_SPACING_X:Number = 10;
		private static const SELL_SPACING_Y:Number = 10;
		
		public static var DEFAULT_LOGIN_LABEL:String = "login";
		public static var DEFAULT_PASSWORD_LABEL:String = "password";
		
		private var _loginButton:GLabeledButton;
		
		private var _loginInput:TextField;
		private var _passwordInput:TextField;
		
		private static const ENABLED_BORDER_COLOR:uint = 0x33cc00;
		private static const LOCKED_BORDER_COLOR:uint = 0xff0000;
		
		private var _connection:ClientConnectionController;
		
		// -- конструктор
		public function LoginForm(connection:ClientConnectionController)
		{
			super();
			
			_connection = connection;
			
			var inputTformat:TextFormat = new TextFormat("Calibri", 16, 0x666666, null, null, null, null, null, null, 6, 6);
			
			_loginInput = new TextField();
			_loginInput.defaultTextFormat = inputTformat;
			_loginInput.type = "input";
			_loginInput.border = true;
			_loginInput.borderColor = ENABLED_BORDER_COLOR;
			_loginInput.width = 200;
			_loginInput.height = 25;
			_loginInput.x = PADDING_X;
			_loginInput.y = PADDING_Y;
			_loginInput.maxChars = 16;
			_loginInput.restrict = "a-zA-Z0-9";
			_loginInput.text = DEFAULT_LOGIN_LABEL;
			this.addChild(_loginInput);
			
			_passwordInput = new TextField();
			_passwordInput.defaultTextFormat = inputTformat;
			_passwordInput.type = "input";
			_passwordInput.border = true;
			_passwordInput.borderColor = ENABLED_BORDER_COLOR;
			_passwordInput.width = 200;
			_passwordInput.height = 25;
			_passwordInput.x = PADDING_X;
			_passwordInput.y = _loginInput.y + _loginInput.height + SELL_SPACING_Y;
			_passwordInput.maxChars = 16;
			_passwordInput.restrict = "a-zA-Z0-9";
			_passwordInput.displayAsPassword = true;
			_passwordInput.text = DEFAULT_PASSWORD_LABEL;
			this.addChild(_passwordInput);
			
			_loginButton = new GLabeledButton("loginButton", "ENTER", 95, 35);
			_loginButton.x = PADDING_X;
			_loginButton.y = _passwordInput.y + _passwordInput.height + SELL_SPACING_Y;
			_loginButton.enabled = false;
			this.addChild(_loginButton);
			
			if (!_connection.connected)
				_connection.addEventListener(Event.CONNECT, connectHandler);
			else
				connectHandler();
		}
		
		public function init():void
		{
			_loginInput.addEventListener(FocusEvent.FOCUS_IN, inputFocusInHandler);
			_loginInput.addEventListener(FocusEvent.FOCUS_OUT, inputFocusOutHandler);
			_loginInput.addEventListener(TextEvent.TEXT_INPUT, textFieldInputHandler);
			_passwordInput.addEventListener(FocusEvent.FOCUS_IN, inputFocusInHandler);
			_passwordInput.addEventListener(FocusEvent.FOCUS_OUT, inputFocusOutHandler);
			_passwordInput.addEventListener(TextEvent.TEXT_INPUT, textFieldInputHandler);
			_loginButton.handler = loginButtonClickHandler;
			
			CONFIG::debug {
				_loginInput.text = "alex";
				_passwordInput.text = "alex";
			}
		}
		
		private function connectHandler(event:Event = null):void
		{
			_loginButton.enabled = true;
			CONFIG::debug {
				loginButtonClickHandler(null);
			}
		}
		
		public function clear():void
		{
			_loginInput.removeEventListener(FocusEvent.FOCUS_IN, inputFocusInHandler);
			_loginInput.removeEventListener(FocusEvent.FOCUS_OUT, inputFocusOutHandler);
			_loginInput.removeEventListener(TextEvent.TEXT_INPUT, textFieldInputHandler);
			_passwordInput.removeEventListener(FocusEvent.FOCUS_IN, inputFocusInHandler);
			_passwordInput.removeEventListener(FocusEvent.FOCUS_OUT, inputFocusOutHandler);
			_passwordInput.removeEventListener(TextEvent.TEXT_INPUT, textFieldInputHandler);
			_loginButton.handler = null;
		}
		
		// обработчик события получения фокуса input-полем формы
		private function inputFocusInHandler(event:FocusEvent):void
		{
			var input:TextField = event.currentTarget as TextField;
			if (input == _loginInput && input.text == DEFAULT_LOGIN_LABEL) {
				input.text = "";
				input.textColor = 0x000000;
			}
			else if (input == _passwordInput && input.text == DEFAULT_PASSWORD_LABEL) {
				input.text = "";
				input.textColor = 0x000000;
			}
		}
		
		// обработчик события потери фокуса input-полем формы
		private function inputFocusOutHandler(event:FocusEvent):void
		{
			var input:TextField = event.currentTarget as TextField;
			if (input == _loginInput && input.text == "") {
				input.text = DEFAULT_LOGIN_LABEL;
				input.textColor = 0x666666;
			} else if (input == _passwordInput && input.text == "") {
				input.text = DEFAULT_PASSWORD_LABEL;
				input.textColor = 0x666666;
			}
		}
		
		// обработчик события ввода символов в поля формы
		private function textFieldInputHandler(event:TextEvent):void
		{
			var input:TextField = event.currentTarget as TextField;
			if (input.borderColor == LOCKED_BORDER_COLOR)
				input.borderColor == ENABLED_BORDER_COLOR;
		}
		
		// обработчик активации кнопки логина
		private function loginButtonClickHandler(button:BaseButton):void
		{
			var valid:Boolean = true;
			if (_loginInput.text.length < 3 || _loginInput.text == DEFAULT_LOGIN_LABEL) {
				_loginInput.borderColor = LOCKED_BORDER_COLOR;
				valid = false;
			} else {
				_loginInput.borderColor = ENABLED_BORDER_COLOR;
			}
			if (_passwordInput.text.length < 3 || _passwordInput.text == DEFAULT_PASSWORD_LABEL) {
				_passwordInput.borderColor = LOCKED_BORDER_COLOR;
				valid = false;
			} else {
				_passwordInput.borderColor = ENABLED_BORDER_COLOR;
			}
			if (valid) submit();
		}
		
		// отправка данных формы
		private function submit():void
		{
			_loginButton.enabled = false;
			_connection.login(_loginInput.text, _passwordInput.text, loginResultHandler);
		}
		
		// получение результата авторизации
		private function loginResultHandler(result:Object):void
		{
			_loginButton.enabled = true;
			
			if (!result || result['error']) {
				_loginInput.borderColor = LOCKED_BORDER_COLOR;
				_passwordInput.borderColor = LOCKED_BORDER_COLOR;
				return;
			}
			var data:Object = {
				user_id: result['user_id'],
				auth_key: result['auth_key']
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		// обработчик изменения размера внешнего контейнера
		public function resize(width:Number, height:Number):void
		{
			var w:Number = _loginInput.width + 2 * PADDING_X;
			var h:Number = _loginButton.y + 35 + PADDING_Y;
			x = (width - w) / 2;
			y = (height - h) / 2;
		}
	}
}