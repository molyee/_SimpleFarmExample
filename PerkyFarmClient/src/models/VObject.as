package models
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * Класс объектов, заполняющих свои поля входящими данными
	 * ...
	 * @author Alex Sarapulov
	 */
	[Event(name="change", type="flash.events.Event")]
	public class VObject extends EventDispatcher
	{
		/**
		 * Конструктор класса
		 * 
		 * @param	source Данные полей объекта
		 * 
		 */
		public function VObject(source:Object = null)
		{
			if (source)
				init(source);
		}
		
		/**
		 * Заполнение полей объекта данными
		 * 
		 * @param	source Данные поленй объекта
		 */
		protected function init(source:Object):void
		{
			if (!source)
				return;
			for (var key:String in source) {
				if (!key in this) continue;
				try {
					this[key] = source[key];
				} catch (e:Error) { }
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}