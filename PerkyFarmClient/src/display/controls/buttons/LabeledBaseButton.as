package display.controls.buttons
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class LabeledBaseButton extends BaseButton
	{
		// поле лейбла кнопки
		protected var _labelTfield:TextField;
		// свойство получения/установки текста кнопки
		public function get label():String { return _labelTfield.text; }
		public function set label(value:String):void {
			_labelTfield.text = value;
			_labelTfield.x = _normalState.x + (_normalState.width - _labelTfield.width) / 2;
			_labelTfield.y = _normalState.y + (_normalState.height - _labelTfield.height) / 2;
		}
		
		// -- конструктор
		public function LabeledBaseButton(id:String, label:String, textFormat:TextFormat,
										  normalState:DisplayObject, disabledState:Array = null,
										  activeState:Array = null, downState:Array = null, embedFonts:Boolean = false)
		{
			super(id, normalState, disabledState, activeState, downState);
			
			_labelTfield = new TextField();
			_labelTfield.defaultTextFormat = textFormat;
			_labelTfield.autoSize = "left";
			_labelTfield.selectable = false;
			_labelTfield.embedFonts = embedFonts;
			this.addChild(_labelTfield);
			
			this.label = label;
		}
	}
}