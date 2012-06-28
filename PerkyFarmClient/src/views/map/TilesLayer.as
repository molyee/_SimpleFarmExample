package views.map 
{
	import display.utils.BitmapCache;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import math.Isometric;
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class TilesLayer extends Sprite
	{
		// -- константы
		
		/** Цвет рамки ячейки */
		public static const BOUNDS_COLOR:uint = 0x000000;
		/** Альфа канал рамки ячейки */
		public static const BOUNDS_ALPHA:Number = 0.3;
		
		/** Цвет доступной для постройки ячейки */
		public static const ENABLED_COLOR:uint = 0x6633ff00;
		/** Альфа канал доступной для постройки ячейки */
		public static const ENABLED_ALPHA:Number = 0.5;
		/** Цвет недоступной для постройки ячейки */
		public static const BUSY_COLOR:uint = 0x66ffffff;
		/** Альфа канал недоступной для постройки ячейки */
		public static const BUSY_ALPHA:Number = 0.5;
		
		protected var _normalWidth:Number;
		/**
		 * Ширина области сетки ячеек (пиксели)
		 * 
		 */
		public function get normalWidth():Number { return _normalWidth; }
		
		protected var _normalHeight:Number;
		/**
		 * Высота области сетки ячеек (пиксели)
		 * 
		 */
		public function get normalHeight():Number { return _normalHeight; }
		
		protected var _size:int;
		/**
		 * Размер сетки ячеек (количество ячеек квадратной сетки)
		 * 
		 */
		public function get size():int { return _size; }
		
		protected var _xpos:Number;
		/**
		 * Горизонтальное смещение карты ячеек от начала координат карты
		 * 
		 */
		public function get xpos():Number { return _xpos; }
		
		protected var _ypos:Number;
		/**
		 * Вертикальное смещение карты ячеек от начала координат карты
		 * 
		 */
		public function get ypos():Number { return _ypos; }
		
		/**
		 * Визуализация рамок ячеек
		 * @private
		 */
		protected var _cellsBounds:Bitmap;
		
		/**
		 * Триггер показа рамок ячеек
		 * @private
		 */
		protected var _cellsVisible:Boolean;
		
		protected var _objectsMap:Object;
		/**
		 * Ссылка на карту заполнения ячеек (только запись)
		 * 
		 */
		public function set objectsMap(value:Object):void { _objectsMap = value; };
		
		/**
		 * Триггер запуска проверки ячеек
		 * @private
		 */
		protected var _checkingPath:Boolean;
		
		/**
		 * Проверяемый объект
		 * @private
		 */
		protected var _currentObject:IMapObjectView;
		
		/**
		 * Предыдущая целевая позиция
		 * @private
		 */
		protected var _lastTargetCell:Point; // 
		
		/**
		 * Предыдущие залитые ячейки
		 * @private
		 */
		protected var _lastColoredPositions:Array;
		
		/**
		 * Растровый объект содержащий подсвеченные ячейки
		 * @private
		 */
		protected var _coloredBitmap:Bitmap;
		
		/**
		 * Векторный объект, рисующий картинку подсвеченных ячеек
		 * @private
		 */
		protected var _coloredDrawer:Shape;
		
		/**
		 * Ячейки, требующие заливки
		 * @private
		 */
		protected var _coloredPositions:Object;
		
		/**
		 * Конструктор уровня ячеек
		 * 
		 * @param	size Размер сетки ячеек (количество ячеек любой из сторон)
		 * @param	horizontalCellSize Ширина ромба ячейки (пиксели)
		 * @param	verticalCellSize Высота ромаб ячейки (пиксели)
		 * 
		 */
		public function TilesLayer(size:int, horizontalCellSize:Number = 100, verticalCellSize:Number = 50) 
		{
			super();
			
			mouseChildren = false;
			mouseEnabled = false;
			
			_size = size;
			_normalWidth = _size * horizontalCellSize;
			_normalHeight = _size * verticalCellSize;
			_xpos = Isometric.PADDING_X;
			_ypos = Isometric.PADDING_Y + _size * verticalCellSize / 2;
			
			_coloredPositions = { };
			_coloredBitmap = new Bitmap();
			_coloredDrawer = new Shape();
			
			Isometric.CELL_WIDTH = horizontalCellSize;
			Isometric.CELL_HEIGHT = verticalCellSize;
			Isometric.MAP_WIDTH = _normalWidth;
			Isometric.MAP_HEIGHT = _normalHeight;
			
			//CONFIG::debug {
				//showCells();
				//setCheckingPath(3, 4);
			//}
		}
		
		/**
		 * Показать рамки всех ячеек
		 * 
		 */
		public function showCells():void
		{
			if (_cellsVisible) return;
			if (_cellsBounds == null)
				prepareCellsBounds();
			this.addChildAt(_cellsBounds, 0);
		}
		
		/**
		 * Скрыть рамки всех ячеек
		 * 
		 */
		public function hideCells():void
		{
			if (!_cellsVisible) return;
			this.removeChild(_cellsBounds);
		}
		
		/**
		 * Подготовка сетки ячеек
		 * 
		 */
		protected function prepareCellsBounds():void
		{
			_cellsBounds = new Bitmap();
			var startPoint:Point;
			var endPoint:Point;
			var i:int;
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(1, BOUNDS_COLOR, BOUNDS_ALPHA);
			for (i = 0; i <= _size; i++) { // рисуем линии рамок с северо-востока на юго-запаз
				startPoint = Isometric.normalToIsometric(i, 0);
				endPoint = Isometric.normalToIsometric(i, _size);
				shape.graphics.moveTo(startPoint.x, startPoint.y);
				shape.graphics.lineTo(endPoint.x, endPoint.y);
			}
			for (i = 0; i <= _size; i++) { // рисуем линии рамок с северо-запада на юго-восток
				startPoint = Isometric.normalToIsometric(0, i);
				endPoint = Isometric.normalToIsometric(_size, i);
				shape.graphics.moveTo(startPoint.x, startPoint.y);
				shape.graphics.lineTo(endPoint.x, endPoint.y);
			}
			// создаем растровую карту ячеек
			_cellsBounds.bitmapData = BitmapCache.drawBitmapData(shape);
			_cellsBounds.x = Isometric.PADDING_X;
			_cellsBounds.y = Isometric.PADDING_Y;
		}
		
		/**
		 * Запуск проверки ячеек вокруг объекта карты
		 * 
		 * @param	object Визуальный объект на карте
		 * 
		 */
		public function setCheckingObject(object:IMapObjectView):void
		{
			if (_checkingPath)
				clearCheckingObject();
			_checkingPath = true;
			_currentObject = object;
			movePositionHandler();
			this.addChildAt(_coloredBitmap, 0);
			this.addEventListener(Event.ENTER_FRAME, movePositionHandler);
		}
		
		/**
		 * Остановка проверки ячеек
		 * 
		 */
		public function clearCheckingObject():void
		{
			this.removeEventListener(Event.ENTER_FRAME, movePositionHandler);
			if (_coloredBitmap && _coloredBitmap.parent)
				_coloredBitmap.parent.removeChild(_coloredBitmap);
			_currentObject = null;
			_lastTargetCell = null;
			_checkingPath = false;
		}
		
		/**
		 * Обработчик изменения положения мыши
		 * 
		 * @param	event Событие, оповещающее о необходимости проверки и обновления позиционной ячейки
		 * @private
		 */
		protected function movePositionHandler(event:Event = null):void
		{
			if (!_checkingPath || !_currentObject)
				return;
			var targetCell:Point = getTargetCell(mouseX, mouseY);
			if (_lastTargetCell && _lastTargetCell.x == targetCell.x && _lastTargetCell.y == targetCell.y)
				return;
			
			//trace(targetCell.x, targetCell.y);
			_currentObject.setPosition(targetCell.x + 1, targetCell.y);
				
			var positions:Array = getPositions(targetCell, _currentObject);
			if (_lastColoredPositions != null) {
				for each (var pos:Point in _lastColoredPositions) {
					var index:int = positions.indexOf(pos);
					if (index != -1) continue;
					clearPositionColor(pos.x, pos.y);
				}
			}
			coloringPositions(positions);
			_lastColoredPositions = positions;
			
			_lastTargetCell = targetCell;
			
			drawColoredCells();
		}
		
		/**
		 * Получение позиции ячейки по координатам текущего контейнера
		 * 
		 * @param	xpos X-позиция точки на карте (пиксели)
		 * @param	ypos Y-позиция точки на карте (пиксели)
		 * @return Позиция ячейки в сетке
		 * 
		 */
		public function getTargetCell(x:Number, y:Number):Point
		{
			var normalPosition:Point = Isometric.isometricToNormal(x, y);
			return normalPosition;
		}
		
		/**
		 * Проверка на отсутствие объектов в ячейке
		 * 
		 * @param	xpos X-позиция ячейки в сетке
		 * @param	ypos Y-позиция ячейки в сетке
		 * @param	ignoredObject Игнорируемый объект при проверке (если перемещаем
		 * какой-то объект, то его привязанную позицию нужно игнорировать, чтобы можно
		 * было ставить объект на прежнее место)
		 * @return Доступность позиции для постройки, true - место свободно, постройка доступна
		 * @private
		 */
		protected function checkPosition(xpos:int, ypos:int, ignoredObject:* = null):Boolean
		{
			var cellObject:* = getObject(xpos, ypos);
			return cellObject == null || cellObject == ignoredObject;
		}
		
		/**
		 * Получение объекта, находящегося в ячейке
		 * 
		 * @param	xpos X-позиция ячейки в сетке
		 * @param	ypos Y-позиция ячейки в сетке
		 * @return Объект, привязанный к ячейке (установленный в ячейку)
		 * 
		 */
		public function getObject(xpos:int, ypos:int):*
		{
			if (xpos < 0 || xpos >= _size || ypos < 0 || ypos >= _size)
				return null;
			var object:* = _objectsMap[xpos + "_" + ypos];
			return object;
		}
		
		/**
		 * Получение ячеек вокруг целевой позиции с учетом размеров целевого объекта
		 * 
		 * @param	targetCell Координаты целевой ячейки (X и Y позиции ячейки)
		 * @param	object Целевой объект, имеющий собственнуй размер
		 * @return Массив ячеек, находящихся под объектом
		 * 
		 */
		public function getPositions(targetCell:Point, object:IMapObjectView):Array
		{
			var positions:Array = [];
			var i0:int = targetCell.x - int(object.w / 2);
			var j0:int = targetCell.y - int(object.h / 2);
			var n:int = i0 + object.w;
			var m:int = j0 + object.h;
			for (var i:int = i0; i < n; i++) {
				for (var j:int = j0; j < m; j++) {
					positions.push(new Point(i, j));
				}
			}
			return positions;
		}
		
		/**
		 * Заливка ячеек цветом
		 * 
		 * @param	positions Массив подцвеченных позиций
		 * @private
		 */
		protected function coloringPositions(positions:Array):void
		{
			if (!positions || positions.length == 0) return;
			for each (var pos:Point in positions) {
				if (checkPosition(pos.x, pos.y, _currentObject.mapObject))
					setPositionColor(pos.x, pos.y, ENABLED_COLOR, ENABLED_ALPHA);
				else
					setPositionColor(pos.x, pos.y, BUSY_COLOR, BUSY_ALPHA);
			}
			drawColoredCells();
		}
		
		/**
		 * Установка цвета ячейки
		 * 
		 * @param	xpos X-позиция ячейки в сетке
		 * @param	ypos Y-позиция ячейки в сетке
		 * @param	color Цвет ячейки
		 * @param	alpha Альфа канал ячейки
		 * @private
		 */
		protected function setPositionColor(xpos:int, ypos:int, color:uint, alpha:Number = 1):void
		{
			if (xpos < 0 || xpos >= _size || ypos < 0 || ypos >= _size)
				return;
			_coloredPositions[xpos + "_" + ypos] = [color, alpha];
		}
		
		/**
		 * Очистка цвета ячейки
		 * 
		 * @param	xpos X-позиция ячейки в сетке
		 * @param	ypos Y-позиция ячейки в сетке
		 * @private
		 */
		protected function clearPositionColor(xpos:int, ypos:int):void
		{
			delete _coloredPositions[xpos + "_" + ypos];
		}
		
		/**
		 * Отрисовка ячеек, которым назначен цвет
		 * 
		 * @private
		 */
		protected function drawColoredCells():void
		{
			_coloredDrawer.graphics.clear();
			var cellName:String;
			var p:Array;
			var colorData:Array;
			for (cellName in _coloredPositions) {
				p = cellName.split("_");
				colorData = _coloredPositions[cellName];
				drawCell(_coloredDrawer.graphics, int(p[0]), int(p[1]), colorData[0], colorData[1]);
			}
			var bounds:Rectangle = _coloredDrawer.getBounds(_coloredDrawer);
			_coloredBitmap.bitmapData = BitmapCache.drawBitmapData(_coloredDrawer, bounds);
			_coloredBitmap.x = bounds.x;
			_coloredBitmap.y = bounds.y;
		}
		
		/**
		 * Отрисовка одной ячейки (ромба)
		 * 
		 * @param	graphics Объект графики, обрабатывающий отрисовку
		 * @param	xpos X-позиция ячейки в сетке
		 * @param	ypos Y-позиция ячейки в сетке
		 * @param	color Цвет заливки ячейки
		 * @param	alpha Альфа канал заливки ячейки
		 */
		protected function drawCell(graphics:Graphics, xpos:int, ypos:int, color:uint, alpha:Number = 1):void
		{
			var v:Vector.<Point> = new Vector.<Point>(4);
			v[0] = Isometric.normalToIsometric(xpos, ypos);
			v[1] = Isometric.normalToIsometric(xpos + 1, ypos);
			v[2] = Isometric.normalToIsometric(xpos + 1, ypos + 1);
			v[3] = Isometric.normalToIsometric(xpos, ypos + 1);
			graphics.beginFill(color, alpha);
			graphics.moveTo(v[0].x, v[0].y);
			for (var i:int = 1; i < 4; i++) {
				graphics.lineTo(v[i].x, v[i].y);
			}
			graphics.endFill();
		}
		
		
	}

}