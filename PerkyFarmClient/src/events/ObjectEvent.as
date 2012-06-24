package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ObjectEvent extends Event 
	{
		protected var _data:*;
		public function get data():* { return _data; }
		
		public function ObjectEvent(type:String, data:*, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			_data = data;
			super(type, bubbles, cancelable);
		}
		
		public function dispose():void
		{
			stopImmediatePropagation();
			_data = null;
		}
	}

}