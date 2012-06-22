package models 
{
	/**
	 * ...
	 * @author alex
	 */
	public class VObjectTypes 
	{
		public static const USER_TYPE:String = "user_type";
		public static const ITEM_TYPE:String = "item_type";
		
		public static const types:Object = {
			"user_type": User,
			"item_type": Item
		}
		
		public static function getClass(objectType:String):Class
		{
			return _types[objectType] as Class;
		}
	}

}