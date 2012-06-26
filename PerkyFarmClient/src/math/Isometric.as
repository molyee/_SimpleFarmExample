package math 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class Isometric 
	{
		public static var CELL_WIDTH:Number = 100;
		public static var CELL_HEIGHT:Number = 50;
		
		public static var MAP_WIDTH:Number = 4096;
		public static var MAP_HEIGHT:Number = 2048;
		
		public static var PADDING_X:Number = 200;
		public static var PADDING_Y:Number = 200;
		
		public static function normalToIsometric(xpos:int, ypos:int):Point
		{
			var res:Point = new Point();
			res.x = CELL_WIDTH / 2 * Number(ypos + xpos) + PADDING_X;
			res.y = CELL_HEIGHT / 2 * Number(ypos - xpos) + PADDING_Y + MAP_HEIGHT / 2;
			return res;
		}
		
		public static function isometricToNormal(ix:Number, iy:Number):Point
		{
			ix -= PADDING_X;
			iy -= PADDING_Y + MAP_HEIGHT / 2;
			var res:Point = new Point();
			res.x = Math.floor(ix / CELL_WIDTH - iy / CELL_HEIGHT);
			res.y = Math.floor(ix / CELL_WIDTH + iy / CELL_HEIGHT);
			return res;
		}
	}

}