package net.serialize 
{
	/**
	 * Интерфейс класса-сериализатора
	 * ...
	 * @author Alex Sarapulov
	 */
	public interface ISerializer 
	{
		/**
		 * Десериализация данных
		 * 
		 * @param	data Десериализуемые данные
		 * @return Десериализованные данные
		 */
		function decode(data:*):*;
		
		/**
		 * Сериализация данных
		 * 
		 * @param	object Сериализуемые данные
		 * @return Сериализованные данные
		 */
		function encode(object:*):*;
	}
	
}