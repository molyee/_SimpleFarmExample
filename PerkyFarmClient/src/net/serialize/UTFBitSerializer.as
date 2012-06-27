package net.serialize 
{
	import flash.utils.ByteArray;

	/**
	 * Класс кодирующий данные из строкового формата в битовый формат
	 * и декодирующий обратно
	 * ...
	 * @author Alex Sarapulov
	 */
	public class UTFBitSerializer implements ISerializer 
	{
		/**
		 * Конструктор класса сериализатора
		 * 
		 */
		public function UTFBitSerializer() 
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
			var str:String = String(data);
			var result:ByteArray = new ByteArray();
			for (var i:int = 0; i < str.length; ++i) {
				result.writeShort(str.charCodeAt(i));
			}
			result.position = 0;
			return result;
		}
		
		/**
		 * Сериализация данных
		 * 
		 * @param	object Сериализуемые данные
		 * @return Сериализованные данные
		 */
		public function decode(object:*):* 
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