package net.serialize 
{
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class UTFBitSerializer implements ISerializer 
	{
		
		public function UTFBitSerializer() 
		{
			
		}
		
		public function decode(data:*):Object 
		{
			var str:String = String(data);
			var result:ByteArray = new ByteArray();
			for (var i:int = 0; i < str.length; ++i) {
				result.writeShort(str.charCodeAt(i));
			}
			result.position = 0;
			return result;
		}
		
		public function encode(object:Object):* 
		{
			var ba:ByteArray = object as ByteArray;
			var origPos:uint = ba.position;
			var result:Array = new Array();

			for (ba.position = 0; ba.position < ba.length - 1; ) {
				result.push(ba.readShort());
			}

			if (ba.position != ba.length)
				result.push(ba.readByte() << 8);

			ba.position = origPos;
			return String.fromCharCode.apply(null, result);
		}
		
	}

}