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
		/**
		 * Конструктор класса сериализатора
		 * 
		 */
		public function XMLSerializer() 
		{
			
		}
		
		/**
		 * Десериализация данных
		 * 
		 * @param	data Десериализуемые данные
		 * @return Десериализованные данные
		 */
		public function encode(data:*):* 
		{
			return com.adobe.serialization.json.JSON.encode(data);
		}
		
		/**
		 * Сериализация данных
		 * 
		 * @param	object Сериализуемые данные
		 * @return Сериализованные данные
		 */
		public function decode(object:*):*
		{
			return com.adobe.serialization.json.JSON.decode(object);
		}
	}
}