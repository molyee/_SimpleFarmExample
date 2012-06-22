package models.items
{
	/**
	 * класс размера элемента карты
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ItemSize
	{
		// горизонтальный размер объекта
		private var _width:uint;
		public function get width():uint { return _width; }
		
		// вертикальный размер объекта
		private var _height:uint;
		public function get height():uint { return _height; }
		
		// -- конструктор
		public function ItemSize(width:uint = 1, height:uint = 1)
		{
			_width = width;
			_height = height;
		}
	}
}