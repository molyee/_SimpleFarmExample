package models 
{
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class SkinData 
	{
		protected var _itemType:String;
		public function get itemType():String { return _itemType; }
		
		protected var _level:uint = 1;
		public function get level():uint { return _level; }
		
		protected var _isDefault:Boolean;
		public function get isDefault():Boolean { return _isDefault; }
		
		protected var _offsetX:int;
		public function get offsetX():int { return _offsetY; }
		
		protected var _offsetY:int;
		public function get offsetY():int { return _offsetY; }
		
		protected var _url:String;
		public function get url():String { return _url; }
		
		public function SkinData(itemType:String, level:uint = 1, offsetX:int = 0, offsetY:int = 0, isDefault:Boolean = false) 
		{
			_itemType = itemType;
			_level = level;
			_offsetX = offsetX;
			_offsetY = offsetY;
			_isDefault = isDefault;
		}
		
	}

}