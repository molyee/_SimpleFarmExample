package net.serialize 
{
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public interface ISerializer 
	{
		function decode(data:*):Object;
		
		function encode(object:Object):*;
	}
	
}