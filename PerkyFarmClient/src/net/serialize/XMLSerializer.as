package net.serialize 
{
	import com.serialization.json.JSON;
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class XMLSerializer implements ISerializer 
	{
		
		public function XMLSerializer() 
		{
			
		}
		
		public function decode(data:*):Object 
		{
			//return XML(data);
			return com.serialization.json.JSON.deserialize(data);
		}
		
		public function encode(object:Object):* 
		{
			//return XML(object).toXMLString();
			return com.serialization.json.JSON.serialize(object);
		}
		
	}

}