package models
{
	import flash.geom.Point;
	
	import models.Item;
	import models.VObject;
	
	/**
	 * Класс объекта пользователя (игрока)
	 * ...
	 * @author Alex Sarapulov
	 */
	public class User extends VObject
	{
		/**
		 * Текущее значение уникального идентификатора объекта
		 * 
		 */
		[Bindable]
		public var item_uuid:int;
		
		/**
		 * Уникальный идентификатор пользователя
		 * 
		 */
		public var id:String;
		
		/**
		 * Список объектов карты пользователя
		 * 
		 */
		public var items:Object = {};
		
		/**
		 * Инвентарь пользователя (список объектов собранных с карты)
		 * 
		 */
		public var inventory:Object = {};
		
		/**
		 * Триггер авторизованности пользователя
		 * 
		 */
		[Bindable]
		public var logged:Boolean;
		
		[Bindable]
		protected var _numItems:uint;
		/**
		 * Количество объектов на карте пользователя
		 * 
		 */
		public function get numItems():uint { return _numItems; }
		
		[Bindable]
		protected var _numInventoryItems:uint;
		/**
		 * Количество элементов в инвентаре пользователя
		 * 
		 */
		public function get numInventoryItems():uint { return _numInventoryItems; }
		
		protected var _map:Object;
		/**
		 * Граф, содержащий расположение объектов на карте пользователя
		 * 
		 */
		public function get map():Object {
			return _map != null ? _map : prepareMap();
		}
		
		/**
		 * Конструктор объекта пользователя
		 * 
		 * @param	source Данные полей объекта пользователя
		 * 
		 */
		public function User(source:* = null)
		{
			super(source);
		}
		
		/**
		 * Обновление некоторых свойств извне
		 * 
		 * @param	changes Измененные свойства
		 * @return Резульат действия, true - успешное выполнение
		 * 
		 */
		public function update(changes:Object):Boolean
		{
			// TODO(Alex Sarapulov): добавить валидацию данных (не все можно изменять извне)
			init(changes);
			
			_numItems = countAndFixItems(items);
			_numInventoryItems = countAndFixItems(inventory);
			
			return true;
		}
		
		/**
		 * Посчет количества объектов, а также правка не десериализованных данных
		 * 
		 * @param	itemsData Список объектов
		 * @private
		 */
		protected function countAndFixItems(items:Object):int
		{
			var item:*;
			var counter:int = 0;
			for (var itemID:String in items) {
				item = items[itemID];
				if (!(item is Item))
					items[itemID] = new Item(item);
				counter++;
			}
			return counter;
		}
		
		/**
		 * Добавление готового объекта на карту пользователя
		 * 
		 * @param	itemType Наименование типа объекта
		 * @param	xpos Позиция X на карте ячеек
		 * @param	ypos Позиция Y на карте ячеек
		 * @return Идентификатор добавленного объекта, если null - объект не был добавлен
		 * 
		 */
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
		
		/**
		 * Перемещение объекта по карте
		 * 
		 * @param	itemType Наименование типа объекта
		 * @param	xpos Позиция X на карте ячеек
		 * @param	ypos Позиция Y на карте ячеек
		 * @return Результат перемещения объекта, true - объект был успешно перемещен в указанную позицию
		 * 
		  */
		public function moveItem(itemID:String, xpos:int, ypos:int):Boolean
		{
			var item:Item = getItem(itemID);
			var oldPosition:Point = new Point(item.x, item.y);
			clearItemPosition(item);
			if (!item || !setItemPosition(item, xpos, ypos)) {
				setItemPosition(item, oldPosition.x, oldPosition.y);
				return false;
			}
			return true;
		}
		
		/**
		 * Установка позиции объекта, заполнение ячеек
		 * 
		 * @param	item Объект карты
		 * @param	xpos Позиция X на карте ячеек
		 * @param	ypos Позиция Y на карте ячеек
		 * @return Результат установки объекта в заданную позицию
		 * 
		 */
		protected function setItemPosition(item:Item, xpos:int, ypos:int):Boolean
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
		
		/**
		 * Удаление объекты с карты ячеек пользователя
		 * 
		 * @param	item Удаляемый объект
		 * 
		 */
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
		
		/**
		 * Удаление объекта из списка объектов карты пользователя
		 * 
		 * @param	itemID Идентификатор объекта
		 * @return Результат удаления объекта, true - объект удален
		 * 
		 */
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
		
		/**
		 * Изъятие объекта с карты с получением награды
		 * 
		 * @param	itemID Идентификатор объекта
		 * @return Результат выполнения сбора, true - объект собран
		 * 
		 */
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
		
		/**
		 * Повышение уровня объекта карты пользователя
		 * 
		 * @param	itemID Идентификатор объекта пользователя
		 * @return Результат выполнения апгрейда, true - уровень повышен
		 * 
		 */
		public function upgradeItem(itemID:String):Boolean
		{
			var item:Item = getItem(itemID);
			if (!item) // объект не найден
				return false;
			return item.upgrade();
		}
		
		/**
		 * Повышение уровня объектов карты пользователя
		 * 
		 * @param	listIDs Список идентификаторов объектов, которые требуется обновить
		 * @return Список идентификаторов объектов, которые были обновлены
		 */
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
		
		/**
		 * Получение объекта карты пользователя
		 * 
		 * @param	itemID Идентификатор объекта на карте пользователя
		 * @return Объект на карте пользователя
		 * 
		 */
		public function getItem(itemID:String):Item
		{
			return items[itemID];
		}
		
		/**
		 * Получение идентификаторов объектов, расположенных на карте пользователя
		 * 
		 * @return Массив идентификаторов объектов карты пользователя
		 * 
		 */
		public function getAllItemIDs():Array
		{
			var itemIDs:Array = [];
			for each (var item:Item in items) {
				itemIDs.push(item.id);
			}
			return itemIDs;
		}
		
		/**
		 * Проверка свободного места для установки целевого объекта
		 * 
		 * @param	x Позиция X точки привязки объекта
		 * @param	y Позиция Y точки привязки объекта
		 * @param	size Размер объекта в ячейках по ширине (индекс 0) и высоте (индекс 1)
		 * @return Результат выполнения проверки, true - говорит о том, что место свободно
		 * для постройки или перемещения
		 * 
		 */
		public function checkEmptyPositions(xpos:int, ypos:int, size:Array):Boolean
		{
			var mapLink:Object = map;
			var i0:int = xpos - int(size[0] / 2) - 1;
			if (i0 < 0) return false; // если вышли за левый край карты
			var j0:int = ypos - int(size[1] / 2);
			if (j0 < 0) return false; // если вышли за верхний край карты
			var n:int = i0 + size[0];
			if (n > Model.MAP_SIZE) return false; // если вышли за правый край карты
			var m:int = j0 + size[1];
			if (m > Model.MAP_SIZE) return false; // если вышли за нижний край карты
			for (var i:int = i0; i < n; i++) {
				for (var j:int = j0; j < m; j++) {
					var item:Item = mapLink[i + "_" + j];
					if (!item) continue;
					return false;	
				}
			}
			return true;
		}
		
		/**
		 * Подготовка графа объектов на карте
		 * 
		 * @return Подготовленный граф заполнения позиций карты
		 */
		protected function prepareMap():Object
		{
			// TODO(Alex Sarapulov): проверить, возможно лучше вычислять карту каждый раз,
			// а не хранить ее, чтобы не занимать память
			_map = { };
			for each (var item:Item in items) {
				_map[item.x + "_" + item.y] = item;
			}
			return _map;
		}
		
		/**
		 * Ликвидация объекта пользователя
		 * 
		 */
		public function dispose():void
		{
			id = null;
			items = null;
			_map = null;
		}
	}
}