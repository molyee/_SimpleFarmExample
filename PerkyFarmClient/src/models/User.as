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
		protected function get map():Object {
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
		public function addItem(itemType:String, xpos:int, ypos:int):Boolean
		{
			var itemID:String = item_uuid.toString();
			var item:Item = new Item({ id: itemID, item_type: itemType, x: xpos, y: ypos });
			var itemSize:Array = item.size;
			if (!checkEmptyPosition(xpos, ypos, itemSize))
				return false; // место занято
			var mapLink:Object = map;
			var n:int = xpos + itemSize[0];
			var m:int = ypos + itemSize[1];
			for (var i:int = xpos; i < n; i++) {
				for (var j:int = ypos; j < m; j++) {
					mapLink[i + "_" + j] = item; // заполняем карту
				}
			}
			item.setOwner(id); // обновляем владельца
			items[itemID] = item;
			_numItems++;
			item_uuid++;
			return true;
		}
		
		// перемещение объекта по карте
		public function moveItem(itemID:String, xpos:int, ypos:int):Boolean
		{
			var item:Item = getItem(itemID);
			if (!item || !checkEmptyPosition(xpos, ypos, item.size, item.id))
				return false;
			item.setPosition(xpos, ypos);
			return true;
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
			delete items[item.id]; // перемещаем объект в инвентарь
			inventory.push(item);
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
		public function checkEmptyPosition(x:int, y:int, size:Array, itemID:String = null):Boolean
		{
			var mapLink:Object = map;
			var n:int = x + size[0];
			var m:int = y + size[1];
			for (var i:int = x; i < n; i++) {
				for (var j:int = y; j < m; j++) {
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