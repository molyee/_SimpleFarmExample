package models.items
{
	/**
	 * класс типов элементов карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ItemType
	{
		// TODO(Alex Sarapulov): в будущем вывести все данные о шаблонах объектов в базу данных
		
		// данные о размерах объектов карты
		private static const DEFAULT_SIZE:ItemSize = new ItemSize(1, 1); // размер по умолчанию
		private static const SIZES:Object = {
			"clover": new ItemSize(1, 1),
			"sunflower": new ItemSize(1, 1),
			"potato": new ItemSize(1, 1)
		}
		
		// данные о максимальных уровнях объектов карты
		private static const DEFAULT_MAX_LEVEL:uint = 5; // максимальный уровень по умолчанию
		private static const MAX_LEVELS:Object = {
			"clover": 5,
			"sunflower": 5,
			"potato": 5
		}
		
		// получение размера для определенного типа объекта
		public static function getSize(itemType:String):ItemSize
		{
			var size:ItemSize = SIZES[itemType];
			return size != null ? size : DEFAULT_SIZE;
		}
		
		// получение максимального уровня определенного типа объекта
		public static function maxLevel(itemType:String):uint
		{
			var maxLevel:* = MAX_LEVELS[itemType];
			return maxLevel == undefined ? DEFAULT_MAX_LEVEL : int(maxLevel);
		}
	}
}