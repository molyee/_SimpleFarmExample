package display.utils 
{
	import flash.filters.ColorMatrixFilter;
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class ColorMatrix
	{
		// матрица фильтра - обесцвечивание
		public static const BLACK_AND_WHITE:Array = [0.3086, 0.6094, 0.0820, 0, 0, 
			0.3086, 0.6094, 0.0820, 0, 0, 0.3086, 0.6094, 0.0820, 0, 0, 0, 0, 0, 1, 0];
		
		// матрица фильтра - сепия
		public static const SEPIA:Array = [0.3930000066757202, 0.7689999938011169, 0.1889999955892563, 0, 0, 
			0.3490000069141388, 0.6859999895095825, 0.1679999977350235, 0, 0, 
			0.2720000147819519, 0.5339999794960022, 0.1309999972581863, 0, 0, 
			0, 0, 0, 1, 0];
		
		public static const BLACK_AND_WHITE_FILTERS:Array = [new ColorMatrixFilter(BLACK_AND_WHITE)];
		public static const SEPIA_FILTERS:Array = [new ColorMatrixFilter(SEPIA)];
	}
}