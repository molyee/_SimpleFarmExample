package net.serialize
{
	import com.adobe.serialization.json.JSON;
	
	import net.serialize.ISerializer;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class XMLSerializer implements ISerializer
	{
		
		public function XMLSerializer() 
		{
			
		}
		
		public function encode(data:*):* 
		{
			return com.adobe.serialization.json.JSON.encode(data);
		}
		
		public function decode(object:*):*
		{
			return com.adobe.serialization.json.JSON.decode(object);
		}
	}
}