package events 
{
	import flash.events.Event;
	
	/**
	 * Класс события, содержащий распространяемые данные
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ObjectEvent extends Event 
	{
		protected var _data:*;
		/** Поле с привязанными к объекту события данными (только чтение) */		
		public function get data():* { return _data; }
		
		/**
		 * Конструктор класса события, содержащего привязанные данные
		 * 
		 * @param type Тип события
		 * @param data Данные, привязанные к объекту события
		 * @param bubbles Определяет, является ли событие событием восходящей цепочки
		 * @param cancelable Указывает, можно ли предотвратить поведение, связанное с событием
		 * 
		 */		
		public function ObjectEvent(type:String, data:*, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			_data = data;
			super(type, bubbles, cancelable);
		}
		
		/**
		 * Деструктор объекта
		 * 
		 */		
		public function dispose():void
		{
			stopImmediatePropagation();
			_data = null;
		}
	}

}