package models
{
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class VObject
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
				this[key] = source[key];
			}
		}
	}
}