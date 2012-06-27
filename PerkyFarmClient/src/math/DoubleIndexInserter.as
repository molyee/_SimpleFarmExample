package math 
{
	import flash.utils.Dictionary;
	/**
	 * Класс управляющий быстрой вставкой и удалением объектов в сортированном списке.
	 * Для выбора позиции вставки нового объекта сначала выбирает диапазон сверки (кусок из
	 * общего списка объектов), а потом в этом небольшом диапазоне ищет место вставки объекта
	 * и затем вставляет объект в уже известное место в общем списке.
	 * Класс работает корректно только с целочисленными полями (int).
	 * Целесообразно использовать класс там, где требуется быстрая вставка, удаление и
	 * сортировка объектов по одному полю в очень большом списке объектов. При этом нужно вычислить
	 * оптимальное количество диапазонов и алгоритм их распределения, исходя из усредненного значения
	 * длины сортируемого списка и распределения плотности объектов с близкими значениями сравниваемого поля
	 * ...
	 * @author Alex Sarapulov
	 */
	public class DoubleIndexInserter 
	{
		/**
		 * Константа линейного (равномерного) распределения количества элементов на каждом диапазоне
		 * 
		 */
		public static const LINEAR:String = "linear";
		/**
		 * Константа распределения элементов в виде ломаной линии.
		 * Такой способ распределения целесообразно применять при распределении диапазонов поиска
		 * в виде ромбовой структуры (т.е. у крайних диапазонов количество возможных вхождений очень мало
		 * по сравнению с количеством в центральной области общего списка)
		 * @private
		 */
		public static const BROKEN_LINE:String = "brokenLine"; // пока не реализовано
		
		/**
		 * Текущий способ распределения элементов (способ задания размеров диапазонов)
		 * @private
		 */
		protected var _admeasurement:String;
		
		/**
		 * Наименование поля сравнения объектов
		 * @private
		 */
		protected var _field:String;
		
		/**
		 * Максимальное значение сравниваемого поля объектов,
		 * все что будет выше этого значения попадет в специальный диапазон "end"
		 * @private
		 */
		protected var _max:Number;
		/**
		 * Минимальное значение сравниваемого поля объектов,
		 * все что будет ниже этого значения попадет в специальный диапазон "start"
		 * @private
		 */
		protected var _min:Number;
		
		protected var _indexes:Array;
		/**
		 * Сортированный список объектов по возрастанию значения сравниваемого поля
		 * этих объектов. Сортировки как таковой не происходит, элемент просто вставляется в нужную позицию
		 * 
		 */
		public function get indexes():Array { return _indexes; }
		
		protected var _paths:Dictionary;
		/**
		 * Сортированные диапазоны объектов, также являются списками объектов, но
		 * только небольшого размера, что уменьшает время поиска объекта внутри
		 * 
		 */
		public function get paths():Dictionary { return _paths; }
		
		protected var _nextPathIDs:Dictionary;
		/**
		 * Список идентификаторов следующего за текущим диапазоном, необходим для инкрементного поиска
		 * целевого диапазона или других подобных задач, где необходимо переходить от первого диапазона ко второму
		 * и т.д. или в обратную сторону
		 * 
		 */
		public function get nextPathIDs():Dictionary { return _nextPathIDs; }
		
		protected var _numPaths:int;
		/**
		 * Количество ключевых точек (разделений) между диапазонами
		 * 
		 */
		public function get numPaths():int { return _numPaths; }
		
		
		/**
		 * Конструктор класса создает новое индексное распределение объектов
		 * 
		 * @param	minValue Максимальное значение сравниваемого поля объектов,
		 * все что будет выше этого значения попадет в специальный диапазон "end"
		 * @param	maxValue Минимальное значение сравниваемого поля объектов,
		 * все что будет ниже этого значения попадет в специальный диапазон "start"
		 * @param	fieldName Максимальное значение сравниваемого поля объектов,
		 * все что будет выше этого значения попадет в специальный диапазон "end"
		 * @param	numPaths Количество ключевых точек (разделений) между диапазонами
		 * @param	admeasurement Текущий способ распределения элементов (способ задания размеров диапазонов)
		 * @param	...args Прочие аргументы, которые будут переданы уже алгоритму распределения диапазонов
		 * 
		 */
		public function DoubleIndexInserter(minValue:int, maxValue:int, fieldName:String, numPaths:int = 10, admeasurement:String = "linear", ...args) 
		{
			_admeasurement = admeasurement; // пока доступен функционал только для линейного (равномерного) распределения елементов 
			_min = minValue;
			_max = maxValue;
			_field = fieldName;
			_numPaths = numPaths;
			_indexes = [];
			// запускаем подготовку диапазонов
			preparePaths(args);
		}
		
		/**
		 * Подготовка диапазонов поиска места вставки
		 * 
		 * @param	...args
		 * @private
		 */
		protected function preparePaths(...args):void
		{
			_paths = new Dictionary();
			_nextPathIDs = new Dictionary();
			switch (_admeasurement) {
				case LINEAR: // равномерное распределение
					prepareLinearPaths(args);
					break;
			}
		}
		
		/**
		 * Подготовка диапазонов равномерного распределения сравниваемого параметра объектов
		 * 
		 * @param	...args
		 * @private
		 */
		protected function prepareLinearPaths(...args):void
		{
			var delta:int = _max - _min;
			var pathLen:int = Number(delta) / Number(_numPaths);
			var prevPathID:* = "start";
			var a:Array = [];
			_paths[prevPathID] = a;
			var i:int = _min;
			while (i < _max) {
				prevPathID = addPath(i, prevPathID);
				if (i >= _max - pathLen - 1)
					break;
				i += pathLen;	
			}
			
			addPath("end", prevPathID);
		}
		
		/**
		 * Процедура добавления нового диапазона
		 * 
		 * @param	curPathID Идентификатор добавляемого диапазона
		 * @param	prevPathID Идентификатор предыдущего диапазона для указания связи
		 * @return Идентификатор добавленного диапазона
		 * @private
		 */
		protected function addPath(curPathID:*, prevPathID:*):*
		{
			var path:Array = [];
			_paths[curPathID] = path;
			_nextPathIDs[prevPathID] = curPathID;
			return curPathID;
		}
		
		/**
		 * Вставка нового элемента в индексный список и получение индекса вставки для
		 * для целевого объекта
		 * 
		 * @param	target Целевой объект (объект, который необходимо добавить в список)
		 * @return Значение индекса вставки (позиция в массиве объектов)
		 * 
		 */
		public function insert(target:*):int
		{
			var pathID:* = getPathID(target);
			var path:Array = _paths[pathID];
			var value:int = int(target[_field]);
			var compareTarget:*;
			var compareValue:int;
			var index:int = 0;
			var iPathID:* = pathID;
			var iPath:Array = path;
			
			// looping
			loop: do { // пока не достигли конечного диапазона
				for (var i:int = 0; i < iPath.length; i++) { // проход по диапазону
					// берем сравниваемый объект из диапазона (один за другим)
					compareTarget = iPath[i];
					if (!compareTarget) throw("!");
					compareValue = int(compareTarget[_field]);
					if (value > compareValue) // если текущее значение все же больше
						continue; // то переходим к следующему объекту в диапазоне
					// а если текущее значение равно или меньше сравниваемого
					if (iPathID == pathID) { // если это текущий диапазон
						if (i == 0)
							path.unshift(target);
						else
							path.splice(i, 0, target);
					} else {
						path.push(target);
					}
					index = _indexes.indexOf(compareTarget);
					break loop; // выходим из do-while с вычисленным индексом
				}
				if (iPathID == pathID && !compareTarget) { // если в первом прогоне не найдено ни одного объекта
					if (index != _indexes.length) // выставляем крайний индекс (возможно временно)
						index = _indexes.length;
					path.push(target); // добавляем объект в диапазон
				}
				// переходим к следующему диапазону
				iPathID = _nextPathIDs[iPathID];
				iPath = _paths[iPathID];
			} while (iPathID != "end");
			// end loop
			
			if (index == _indexes.length) {
				_indexes.push(target);
			} else if (index == 0) {
				_indexes.unshift(target);
			} else {
				_indexes.splice(index, 0, target);
			}
			return index;
		}
		
		/**
		 * Удаление элемента из индексного списка
		 * 
		 * @param	target Удаляемый объект
		 * @return Индекс, который был у удаленного объекта списка до удаления этого объекта
		 * 
		 */
		public function remove(target:*):int
		{
			var pathID:* = getPathID(target);
			var path:Array = _paths[pathID];
			var i:int = path.indexOf(target);
			if (i != -1)
				path.splice(i, 1);
			var index:int = _indexes.indexOf(target);
			if (index != -1)
				_indexes.splice(index, 1);
			return index;
		}
		
		/**
		 * Получение диапазона поиска (вставки или удаления) для целевого объекта
		 * 
		 * @param	target Целевой объект
		 * @return Идентификатор диапазона поиска
		 */
		protected function getPathID(target:*):*
		{
			var compareValue:Number = Number(target[_field]);
			if (compareValue < _min) return "start";
			if (compareValue > _max) return "end";
			var pathID:* = "start";
			var lastPathID:*;
			do {
				lastPathID = pathID;
				pathID = _nextPathIDs[pathID];
				if (compareValue >= Number(pathID))
					continue;
				return lastPathID;
			} while (pathID != "end")
			return pathID;
		}
	}

}