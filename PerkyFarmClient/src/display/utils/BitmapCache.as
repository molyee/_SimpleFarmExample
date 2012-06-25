package display.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Утилита позволяющая преобразовывать любые дисплей-объекты в растр.
	 * Целесообразно использовать класс в качестве растрового кешера контейнеров, и векторных объектов
	 * ...
	 * @author Alex Sarapulov
	 */
	public class BitmapCache 
	{
		/**
		 * Отрисовка текущего дисплей-объекта в растр с сохранением размера, учитывая заступы фильтров
		 * 
		 * @param	object Объект, который будет клонирован как растровый дисплей-объект
		 * @param	positionedAsIs Задает смещение объекта (при true), если рамка переданного объекта смещена
		 * относительно внутреннего начала его координат, т.е. рамка объекта не начинается с позиции (0,0)
		 * @return Результирующий растровый объект, являющийся визуальным клоном переданного объекта
		 * 
		 */
		public static function drawBitmap(object:DisplayObject, positionedAsIs:Boolean = false):Bitmap
		{
			var bounds:Rectangle = object.getBounds(object);
			var bitmapData:BitmapData = drawBitmapData(object, bounds);
			var bitmap:Bitmap = new Bitmap(bitmapData);
			if (!positionedAsIs)
				return bitmap;
			bitmap.x = bounds.x;
			bitmap.y = bounds.y;
			return bitmap;
		}
		
		/**
		 * Создание растровых данных, полностью или частично копирующих визуализацию переданного объекта
		 * 
		 * @param	object Объект, для которого будут получены растровые данные
		 * @param	bounds Рамка отрисовки растровых данных объекта, является необязательным параметром и
		 * если он равен null, то берется рамка всего объекта
		 * @return Растровые данные, являющиеся пикселезацией переданного объекта
		 *
		 */
		public static function drawBitmapData(object:DisplayObject, bounds:Rectangle = null):BitmapData
		{
			bounds = bounds || object.getBounds(object);
			var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00000000);
			bitmapData.draw(object, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
			return bitmapData;
		}
	}

}