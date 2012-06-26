package math 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class DoubleIndexInserter 
	{
		public static const LINEAR:String = "linear";
		
		protected var _admeasurement:String;
		
		protected var _field:String;
		
		protected var _max:Number;
		
		protected var _min:Number;
		
		protected var _indexes:Array;
		
		protected var _paths:Dictionary;
		protected var _nextPathIDs:Dictionary;
		
		protected var _numPaths:int;
		
		
		public function DoubleIndexInserter(minValue:Number, maxValue:Number, fieldName:String, numPaths:int = 10, admeasurement:String = "linear", ...args) 
		{
			_admeasurement = admeasurement;
			_min = minValue;
			_max = maxValue;
			_field = fieldName;
			_numPaths = numPaths;
			_indexes = [];
			preparePaths(args);
		}
		
		protected function preparePaths(...args):void
		{
			_paths = new Dictionary();
			_nextPathIDs = new Dictionary();
			switch (_admeasurement) {
				case LINEAR:
					prepareLinearPaths(args);
					break;
			}
		}
		
		protected function prepareLinearPaths(...args):void
		{
			var pathLen:Number = Number(_max - _min) / Number(_numPaths - 1);
			var prevPathID:String = "start";
			var a:Array = [];
			_paths[prevPathID] = a;
			var i:Number = _min;
			while (i < _max) {
				prevPathID = addPath(String(i), prevPathID);
				i += pathLen;
			}
			prevPathID = addPath(String(_max), prevPathID);
			addPath("end", prevPathID);
		}
		
		protected function addPath(curPathID:String, prevPathID:String):String
		{
			var path:Array = [];
			_paths[curPathID] = path;
			_nextPathIDs[prevPathID] = curPathID;
			return curPathID;
		}
		
		public function insert(target:*):int
		{
			var pathID:* = getPathID(target);
			var path:Array = _paths[pathID];
			var value:Number = Number(target[_field]);
			var compareTarget:*;
			var compareValue:Number;
			var index:int = 0;
			for (var i:int = 0; i < path.length; i++) {
				compareTarget = path[i];
				compareValue = Number(compareTarget[_field]);
				if (value > compareValue)
					continue;
				if (i == 0)
					path.unshift(target);
				else if (i == path.length - 1)
					path.push(target);
				else
					path.splice(i, 0, target);
				index = _indexes.indexOf(compareTarget);
				break;
			}
			if (!compareTarget) {
				index = _indexes.length;
				_indexes.push(target);
			} else if (index == 0) {
				_indexes.unshift(target);
			} else {
				_indexes.splice(index, 0, target);
			}
			return index;
		}
		
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