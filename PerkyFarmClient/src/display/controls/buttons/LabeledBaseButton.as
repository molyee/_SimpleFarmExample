package display.controls.buttons
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Класс кнопки с динамическим текстом
	 * ...
	 * @author Alex Sarapulov
	 */
	public class LabeledBaseButton extends BaseButton
	{
		/**
		 * Поле отображаемого текста кнопки
		 * @private
		 */
		protected var _labelTfield:TextField;
		
		/**
		 * Свойство текста кнопки (доступны запись/чтение)
		 * 
		 */
		public function get label():String { return _labelTfield.text; }
		/**
		 * Установщик текста кнопки
		 * @private
		 */
		public function set label(value:String):void {
			_labelTfield.text = value;
			_labelTfield.x = _normalState.x + (_normalState.width - _labelTfield.width) / 2;
			_labelTfield.y = _normalState.y + (_normalState.height - _labelTfield.height) / 2;
		}
		
		/**
		 * Конструктор класса кнопки с текстом
		 * 
		 * @param	id Идентификатор (наименование) кнопки
		 * @param	label Отображаемый текст на кнопке
		 * @param	textFormat Данные о форматирование текста кнопки (шрифт, его размеры и пр.)
		 * @param	normalState Нормальное состояние фона кнопки
		 * @param	disabledState Фильтры для визуализации отключенного состояния
		 * @param	activeState Фильтры для визуализации активного состояния
		 * @param	downState Фильтры для визуализации нажатого состояния
		 * @param	embedFonts Флаг встраивания шрифтов (см. TextField class)
		 * 
		 */
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