package display.utils 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class Isometric 
	{
		public static const CELL_WIDTH:Number = 100;
		public static const CELL_HEIGHT:Number = 50;
		
		public static var MAP_WIDTH:Number = 4096;
		public static var MAP_HEIGHT:Number = 2048;
		
		public static var X0:Number;
		public static var Y0:Number;
		
		public static var WIDTH:Number = 30;
		public static var HEIGHT:Number = 30;
		
		public static function normalToIsometric(xpos:Number, ypos:Number):Point
		{
			var res:Point = new Point();
			res.x = CELL_WIDTH / 2 * (ypos + xpos);
			res.y = CELL_HEIGHT / 2 * (ypos - xpos);
			return res;
		}
		
		public static function isometricToNormal(ix:Number, iy:Number):Point
		{
			var res:Point = new Point();
			res.x = ix / CELL_WIDTH -  iy / CELL_HEIGHT;
			res.y = ix / CELL_WIDTH + iy / CELL_HEIGHT;
			return res;
		}
		
		public static function normalToIsometricRect(rect:Rectangle):Rectangle 
		{
			// TODO(Alex Sarapulov): optimize algorithm
			var top_left:Point = normalToIsometric(rect.topLeft.x, rect.topLeft.y);
			var top_right:Point = normalToIsometric(rect.right, rect.top);
			var bottom_left:Point = normalToIsometric(rect.left, rect.bottom);
			var bottom_right:Point = normalToIsometric(rect.bottomRight.x, rect.bottomRight.y);
			return new Rectangle(top_left.x, top_right.y, bottom_right.x - top_left.x, bottom_left.y - top_right.y);
		}
		
		public static function unionRects(list:Array):Array
		{
			var counter:int = 0;
			var rect:Rectangle;
			var res:Array = [];
			var _list:Array = [];
			for each(var _rect:Rectangle in list) {
				rect = _rect.clone();
				_list.push(rect);
				rect.width += 1;
				rect.height += 1;
				rect.y -= 1;
			}
			var addPoint:Function = function(fromRect:Rectangle, point:Point):void {
				var contains:Boolean = true;
				for each (var r:Rectangle in _list) {
					if (r == fromRect)
						continue;
					if (r.contains(point.x, point.y)) {
						contains = false;
						break;
					}
				}
				if (contains)
					res.push(point);
			}
			for each (rect in list) {
				var x:int, y:int;
				for (x = rect.left, y = rect.top; x <= rect.right; x++)	{
					addPoint(rect, new Point(x, y));
					addPoint(rect, new Point(x, y + rect.height));
					counter++;
				}
				for (x = rect.left, y = rect.top; y <= rect.bottom; y++) {
					addPoint(rect, new Point(x, y));
					addPoint(rect, new Point(x + rect.width, y))
					counter++;
				}
			}
			return removeDoubles(res);
		}
		
		private static function removeDoubles(list:Array):Array
		{
			var res:Array = [];
			var dict:Dictionary = new Dictionary(true);
			for each (var point:Point in list) {
				if (dict[point.x + "_" + point.y] != undefined)
					continue;
				dict[point.x + "_" + point.y] = 1;
				res.push(point);
			}
			return res;
		}
		
	}

}