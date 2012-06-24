package net.serialize 
{
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public interface ISerializer 
	{
		function decode(data:*):*;
		
		function encode(object:*):*;
	}
	
}