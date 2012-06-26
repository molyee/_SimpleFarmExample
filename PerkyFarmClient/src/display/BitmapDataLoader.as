package display 
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * Класс контролирующий загрузку растровых данных
	 * ...
	 * @author Alex Sarapulov
	 */
	public class BitmapDataLoader 
	{
		/**
		 * Ссылка на хранилище ресурсов
		 * 
		 */
		public static var STORAGE:ResourceStorage;
		
		/**
		 * Конструктор класса загрузки растровых данных
		 * 
		 * @param	url URL-адрес (или идентификатор) ресурса с растровыми данными
		 * @param	callback Обработчик получения растровых данных
		 * 
		 */
		public function BitmapDataLoader(url:String, callback:Function) 
		{
			if (!STORAGE) throw("Resource storage is unavailable");
			STORAGE.getResource(url, callback);
		}
		
	}

}