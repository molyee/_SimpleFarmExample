package net.serialize
{
	import com.adobe.serialization.json.JSON;
	
	import models.Item;
	import models.User;
	
	import net.serialize.ISerializer;
	
	/**
	 * ...
	 * @author Alex Sarapulov
	 */
	public class XMLSerializer implements ISerializer
	{
		
		protected static const SIMPLE_TYPES:Object = {
			"string": String,
			"number": Number,
			"integer": int,
			"boolean": Boolean
		}
		
		/**
		 * Конструктор класса сериализатора
		 * 
		 */
		public function XMLSerializer() 
		{
			
		}
		
		/**
		 * Десериализация данных
		 * 
		 * @param	data Десериализуемые данные
		 * @return Десериализованные данные
		 */
		public function encode(data:*):* 
		{
			var type:String = typeof data;
			var xml:XML = writeXMLNode("xml", data);
			return xml;
			//return com.adobe.serialization.json.JSON.encode(data);
		}
		
		/**
		 * Преобразование объекта в XML формат
		 * 
		 * @param name Наименование объекта в контексте
		 * @param data Данные объекта
		 * @return XML представление объекта
		 * 
		 */		
		protected function writeXMLNode(name:String, data:*):XML
		{
			var type:String = typeof data;
			if (data is Array)
				type = "array";
			var xml:XML = new XML('<' + type + ' name="' + name + '" />');
			data = describe(data);
			for (var attr:* in data) {
				trace (attr);
				if (!data.hasOwnProperty(attr)) continue;
				var value:* = data[attr];
				var node:XML;
				if (isSimpleObject(value)) {
					node = getSimpleXMLNode(attr, value);
				} else {
					node = writeXMLNode(attr, value);
				}
				xml.appendChild(node);
			}
			return xml;
		}
		
		/**
		 * Преобразует простой объект в XML формат
		 * 
		 * @param name Название объекта в контексте
		 * @param data Данные объекта
		 * @return XML представление объекта
		 * 
		 */		
		protected function getSimpleXMLNode(name:String, data:*):XML
		{
			var type:String = typeof data;
			var str:String = '<' + type + ' type="' + type + '" name="' + name + '">' + data + '</' + type + '>';
			var node:XML = new XML(str);
			return node;
		}
		
		/**
		 * Присвоение параметров для нединамических классов
		 * 
		 * @param data Объект
		 * @return Объект, являющийся простым представлением входящего объекта в случае,
		 * если это экземпляр нединамического класса
		 * 
		 */		
		protected function describe(data:*):*
		{
			var obj:Object = {};
			if (data is User) {
				obj['id'] = data.id;
				obj['item_uuid'] = data.item_uuid;
				obj['items'] = data.items;
				obj['inventory'] = data.inventory;
				obj['logged'] = data.logged;
				return obj;
			} else if (data is Item) {
				obj['id'] = data.id;
				obj['item_type'] = data.item_type;
				obj['owner_id'] = data.owner_id;
				obj['level'] = data.level;
				obj['x'] = data.x;
				obj['y'] = data.y;
				obj['enabled'] = data.enabled;
				return obj;
			}
			return data;
		}
		
		/**
		 * Сериализация данных
		 * 
		 * @param	object Сериализуемые данные
		 * @return Сериализованные данные
		 */
		public function decode(object:*):*
		{
			var data:* = readXMLNode(new XML(object));
			return data;
			//return com.adobe.serialization.json.JSON.decode(object);
		}
		
		/**
		 * Сериализация вложения
		 * 
		 * @param xml XML-объект
		 * @return Сериализованный объект вложения
		 * 
		 */		
		protected function readXMLNode(xml:XML):*
		{
			if (!xml)
				return null;
			var type:String = xml.@type;
			if (type)
				return readXMLSimple(xml);
			type = xml.toString().substr(1, 3);
			switch (type) {
				case "arr":
					return readXMLArray(xml);
				default:
					return readXMLObject(xml);
			}
		}
		
		/**
		 * Сериализация массива в XML формате
		 * 
		 * @param xml XML-объект, представляющий массив
		 * @return Сериализованный массив
		 * @private
		 */		
		protected function readXMLArray(xml:XML):Array
		{
			var children:XMLList = xml.children();
			var list:Array = new Array(children.length());
			for each (var node:XML in children) {
				var index:int = parseInt(node.@name);
				list[index] = readXMLNode(node);
			}
			return list;
		}
		
		/**
		 * Сериализация объекта в XML формате
		 * 
		 * @param xml XML-объект, представляющий объект
		 * @return Сериализованный объект
		 * @private
		 */		
		protected function readXMLObject(xml:XML):Object
		{
			var object:Object = {};
			for each (var node:XML in xml.children()) {
				var attr:String = node.@name;
				object[attr] = readXMLNode(node);
			}
			return object;
		}
		
		/**
		 * Сериализация простого типа в XML формате
		 * 
		 * @param xml XML-объект, представляющий простой тип
		 * @return Сериализованный простой тип
		 * @private
		 */		
		protected function readXMLSimple(xml:XML):*
		{
			var type:String = xml.@type;
			var cls:Class = SIMPLE_TYPES[type] as Class;
			var res:* = cls(xml.valueOf());
			return res;
		}
		
		// проверка простого типа объекта
		
		/**
		 * Проверяет, является ли объект простым
		 * 
		 * @param data Данные объекта
		 * @return Триггер, true - объект является простым
		 * @private
		 */		
		protected function isSimpleObject(data:*):Boolean
		{
			var type:String = typeof data;
			return isSimpleType(type);
		}
		
		/**
		 * Проверяет, является ли тип объекта простым
		 * 
		 * @param type Тип объекта
		 * @return Триггер, true - тип простой
		 * @private
		 */		
		protected function isSimpleType(type:String):Boolean
		{
			return SIMPLE_TYPES[type] != null;
		}
	}
}