package models
{
	import models.Item;
	import models.VObject;
	
	/**
	 * объект пользователя (игрока)
	 * ...
	 * @author Alex Sarapulov
	 */
	public class User extends VObject
	{
		// текущее значение уникального идентификатора объекта
		public var item_uuid:uint;
		
		// уникальный идентификатор пользователя
		public var id:String;
		
		// список объектов карты пользователя
		public var items:Object = {};
		
		// инвентарь пользователя (список объектов собранных с карты)
		public var inventory:Object = {};
		
		// триггер онлайна
		public var logged:Boolean;
		
		// количество объектов на карте пользователя
		protected var _numItems:uint;
		public function get numItems():uint { return _numItems; }
		
		// количество элементов в инвентаре пользователя
		protected var _numInventoryItems:uint;
		public function get numInventoryItems():uint { return _numInventoryItems; }
		
		// граф, содержащий расположение объектов на карте пользователя
		protected var _map:Object;
		public function get map():Object {
			return _map != null ? _map : prepareMap();
		}
		
		
		// -- конструктор
		public function User(source:* = null)
		{
			super(source);
		}
		
		// обновление некоторых свойств извне (осторожно)
		public function update(changes:Object):Boolean
		{
			// TODO(Alex Sarapulov): добавить валидацию данных (не все можно изменять извне)
			init(changes);
			
			var item:Item;
			var counter:uint = 0;
			for each (item in items) {
				counter++;
			}
			_numItems = counter;
			
			counter = 0;
			for each (item in items) {
				counter++;
			}
			_numInventoryItems = counter;
			
			return true;
		}
		
		// добавление готового объекта на карту пользователя
		public function addItem(itemType:String, xpos:int, ypos:int):String
		{
			var itemID:String = item_uuid.toString();
			var item:Item = new Item({ id: itemID, level: 1, item_type: itemType, x: xpos, y: ypos });
			if (!setItemPosition(item, xpos, ypos))
				return null;
			item.setOwner(id); // обновляем владельца
			items[itemID] = item;
			_numItems++;
			item_uuid++;
			return itemID;
		}
		
		// перемещение объекта по карте
		public function moveItem(itemID:String, xpos:int, ypos:int):Boolean
		{
			var item:Item = getItem(itemID);
			if (!item || !setItemPosition(item, xpos, ypos))
				return false;
			return true;
		}
		
		// установка позиции объекта, заполнение ячеек
		public function setItemPosition(item:Item, xpos:int, ypos:int):Boolean
		{
			var itemSize:Array = item.size;
			if (!checkEmptyPositions(xpos, ypos, itemSize))
				return false; // место занято
			var mapLink:Object = map;
			var i0:int = xpos - int(itemSize[0] / 2) - 1;
			var j0:int = ypos - int(itemSize[1] / 2);
			var n:int = i0 + itemSize[0];
			var m:int = j0 + itemSize[1];
			for (var i:int = i0; i < n; i++) {
				for (var j:int = j0; j < m; j++) {
					mapLink[i + "_" + j] = item; // заполняем карту
				}
			}
			item.setPosition(xpos, ypos);
			return true;
		}
		
		// очистка объекта 
		public function clearItemPosition(item:Item):void
		{
			var itemSize:Array = item.size;
			var mapLink:Object = map;
			var i0:int = item.x - int(itemSize[0] / 2) - 1;
			var j0:int = item.y - int(itemSize[1] / 2);
			var n:int = i0 + itemSize[0];
			var m:int = j0 + itemSize[1];
			for (var i:int = i0; i < n; i++) {
				for (var j:int = j0; j < m; j++) {
					delete mapLink[i + "_" + j]; // опустошаем
				}
			}
		}
		
		// удаление объекта из списка
		public function dropItem(itemID:String):Boolean
		{
			var item:Item = getItem(itemID);
			if (!item) // объект не найден
				return false;
			delete items[item.id];
			item.dispose();
			_numItems--;
			return true;
		}
		
		// изъятие объекта с карты с получением награды
		public function collectItem(itemID:String):Boolean
		{
			var item:Item = getItem(itemID);
			if (!item || item.level < item.maxLevel)
				return false; // объект не найден или не достиг максимального уровня
			clearItemPosition(item);
			delete items[item.id]; // перемещаем объект в инвентарь
			inventory[item.id] = item;
			_numItems--;
			_numInventoryItems++;
			return true;
		}
		
		// повышение уровня объекта карты пользователя
		public function upgradeItem(itemID:String):Boolean
		{
			var item:Item = getItem(itemID);
			if (!item) // объект не найден
				return false;
			return item.upgrade();
		}
		
		// повышение уровня объектов карты пользователя
		public function upgradeItems(listIDs:Array):Array
		{
			var upgradedList:Array = [];
			if (!listIDs) return upgradedList;
			for each (var itemID:String in listIDs) {
				if (upgradeItem(itemID))
					upgradedList.push(itemID);
			}
			return upgradedList;
		}
		
		// получение объекта карты пользователя
		public function getItem(itemID:String):Item
		{
			return items[itemID];
		}
		
		// получение идентификаторов объектов, расположенных на карте пользователя
		public function getAllItemIDs():Array
		{
			var itemIDs:Array = [];
			for each (var item:Item in items) {
				itemIDs.push(item.id);
			}
			return itemIDs;
		}
		
		// проверка свободного места для установки целевого объекта
		public function checkEmptyPositions(x:int, y:int, size:Array, itemID:String = null):Boolean
		{
			var mapLink:Object = map;
			var i0:int = x - int(size[0] / 2) - 1;
			var j0:int = y - int(size[1] / 2);
			var n:int = i0 + size[0];
			var m:int = j0 + size[1];
			for (var i:int = i0; i < n; i++) {
				for (var j:int = j0; j < m; j++) {
					var item:Item = mapLink[i + "_" + j];
					if (!item || item.id == itemID)
						continue;
					return false;	
				}
			}
			return true;
		}
		
		// подготовка графа объектов на карте
		protected function prepareMap():Object
		{
			// TODO(Alex Sarapulov): проверить, возможно лучше вычислять карту каждый раз,
			// а не хранить ее, чтобы не занимать память
			_map = { };
			for each (var itemID:String in items) {
				var item:Item = getItem(itemID);
				_map[item.x + "_" + item.y] = item;
			}
			return _map;
		}
		
		// ликвидация объекта пользователя
		public function dispose():void
		{
			id = null;
			items = null;
			_map = null;
		}
	}
}