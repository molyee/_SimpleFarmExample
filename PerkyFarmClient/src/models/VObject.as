package models
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="change", type="flash.events.Event")]
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class VObject extends EventDispatcher
	{
		// -- конструктор
		public function VObject(source:Object = null)
		{
			init(source);
		}
		
		// заполнение полей объекта данными
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