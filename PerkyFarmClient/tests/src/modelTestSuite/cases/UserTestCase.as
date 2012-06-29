package modelTestSuite.cases
{
	import flexunit.framework.Assert;
	
	import models.Item;
	import models.ItemType;
	import models.User;
	
	/**
	 * Класс проверяет работу не только класса User, но и напрямую зависящий класс Item, а
	 * также частично ItemType
	 * 
	 * @author Alex Sarapulov
	 * 
	 */	
	public class UserTestCase
	{
		// Данные о типах объектов
		private static const ITEMS_DATA_XML:XML =
				<itemTypes imagesPath="/media/items" imgFormat="png" >
					<itemType name="clover" levels="5" w="1" h="1">
						<images>
							<img id="1" x="0" y="3" />
							<img id="2" x="0" y="24" />
							<img id="3" x="0" y="21" />
							<img id="4" x="0" y="20" />
							<img id="5" x="0" y="17" def="1" />
						</images>' +
					</itemType>
					<itemType name="big_sunflower" levels="2" w="3" h="4">
						<images>
							<img id="1" x="0" y="26" />
							<img id="2" x="0" y="17" def="1" />
						</images>
					</itemType>
				</itemTypes>;
		
		// Данные для инициализации пользователя
		private var source:Object = {
				id: "alex",
				item_uuid: 6,
				items: {
					2: {id:"2", item_type:"clover", owner_id:"alex", x:0, y:0, level:5},
					3: {id:"3", item_type:"clover", owner_id:"alex", x:2, y:1, level:1},
					4: {id:"4", item_type:"big_sunflower", owner_id:"alex", x:3, y:4, level:1},
					5: {id:"5", item_type:"big_sunflower", owner_id:"alex", x:20, y:20, level:2}
				},
				inventory: {
					0: {id:"0", item_type:"clover", owner_id:"alex", x:0, y:0, level:5},
					1: {id:"1", item_type:"clover", owner_id:"alex", x:10, y:10, level:5}
				},
				logged: true				
			};
		
		// Объект пользователя		
		private var user:User;
		
		
		[Before]
		public function setUp():void
		{
			ItemType.initItemTypes(ITEMS_DATA_XML);
			user = new User(source);
		}
		
		[After]
		public function tearDown():void
		{
			user = null;
			source = null;
		}
		
		// ------ тесты ------
		
		[Test(order=1)]
		public function testUpdate():void
		{
			var user1:User = new User();
			user1.update(source);
			// проверка равенства основных полей пользователей, к которым применены одни и те же данные, 
			// в одном случае при создании объекта, передав данные в конструкторе, а в другом, обновив объект методом update
			Assert.assertEquals(user.id, user1.id, source.id, "alex");
			Assert.assertEquals(user.item_uuid, user1.item_uuid, source.item_uuid, 6);
			Assert.assertEquals(user.logged, user1.logged, source.logged, true);
			var i:String;
			for (i in source.items) { // проверка равенства полей объектов итемов на карте пользователей (условия см. выше)
				Assert.assertEquals(user.items[i].id, user1.items[i].id, source.items[i].id);
				Assert.assertEquals(user.items[i].item_type, user1.items[i].item_type, source.items[i].item_type);
				Assert.assertEquals(user.items[i].owner_id, user1.items[i].owner_id, source.items[i].owner_id);
				Assert.assertEquals(user.items[i].x, user1.items[i].x, source.items[i].x);
				Assert.assertEquals(user.items[i].y, user1.items[i].y, source.items[i].y);
				Assert.assertEquals(user.items[i].level, user1.items[i].level, source.items[i].level);
			}
			for (i in source.inventory) { // проверка равенства полей объектов в инвентаре пользователей (условия см. выше)
				Assert.assertEquals(user.inventory[i].id, user1.inventory[i].id, source.inventory[i].id);
				Assert.assertEquals(user.inventory[i].item_type, user1.inventory[i].item_type, source.inventory[i].item_type, "clover");
				Assert.assertEquals(user.inventory[i].owner_id, user1.inventory[i].owner_id, source.inventory[i].owner_id);
				Assert.assertEquals(user.inventory[i].x, user1.inventory[i].x, source.inventory[i].x);
				Assert.assertEquals(user.inventory[i].y, user1.inventory[i].y, source.inventory[i].y);
				Assert.assertEquals(user.inventory[i].level, user1.inventory[i].level, source.inventory[i].level);
			}
			user1.update({logged: false}); // проверка изменения одного поля
			Assert.assertFalse(user1.logged);
		}
		
		[Test(order=2)]
		public function testCheckEmptyPositions():void
		{
			for (var i:int = 0; i >= -1; i--) { // проверка безуспешной проверки при отрицательном заступе
				for (var j:int = 0; j >= -1; j--) { // точка 0:0, тоже должна быть занята объектом
					Assert.assertFalse(user.checkEmptyPositions(i, j, [1, 1]));
				}
			}
			var enabled:Boolean;
			for (i = 29; i < 31; i++) { // проверка безуспешной проверки при заступе за максимальное количество ячеек на карте
				for (j = 29; j < 31; j++) {
					enabled = i==29 && j==29;
					Assert.assertEquals(user.checkEmptyPositions(i, j, [1, 1]), enabled);
				}
			}
			for (i = 17; i < 24; i++) { // проверка безуспешной постройки с заступом на территорию занятую другим объектом, с 
				for (j = 16; j < 24; j++) { // размером более чем 1х1, а также проверка успешной постройки со всех сторон вокруг
					enabled = i == 17 || i == 23 || j == 16 || j == 23; // другого объекта без заступа
					Assert.assertEquals(user.checkEmptyPositions(i, j, [3, 3]), enabled);
				}
			}
		}
		
		[Test(order=3)]
		public function testAddItem():void
		{
			for (var i:int = 19; i < 22; i++) {
				for (var j:int = 18; j < 22; j++) {
					Assert.assertNull(user.addItem("clover", i, j));
					Assert.assertNotNull(user.map[i + "_" + j]);
				}
			}
			var itemID:String = user.addItem("big_sunflower", 20, 15);
			Assert.assertNotNull(itemID);
			var item:Item = user.getItem(itemID);
			Assert.assertNotNull(item);
			for (i = 19; i < 22; i++) {
				for (j = 13; j < 17; j++) {
					Assert.assertEquals(user.map[i + "_" + j], item);
				}
			}
		}
		
		[Test(order=4)]
		public function testDropItem():void
		{
			var itemID:String = user.addItem("big_sunflower", 20, 15);
			var item:Item = user.getItem(itemID);
			Assert.assertNotNull(item);
			user.dropItem(item.id);
			for (var i:int = 17; i < 24; i++) {
				for (var j:int = 11; j < 18; j++) {
					Assert.assertNull(user.map[i + "_" + j]);
				}
			}
			Assert.assertNull(user.getItem(itemID));
		}
		
		[Test(order=5)]
		public function testGetAllItemIDs():void
		{
			var itemIDs:Array = user.getAllItemIDs();
			for each (var i:String in itemIDs) {
				Assert.assertNotNull(user.getItem(i));
			}
			Assert.assertEquals(itemIDs.length, user.numItems, 4);
		}
		
		[Test(order=6)]
		public function testMoveItem():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test(order=7)]
		public function testUpgradeItem():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test(order=8)]
		public function testUpgradeItems():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test(order=9)]
		public function testCollectItem():void
		{
			for (var id:String in user.items) {
				var item:Item = user.getItem(id);
				Assert.assertEquals(user.collectItem(id), item.level == item.maxLevel);
				Assert.assertEquals(user.getItem(id) != null, item.level < item.maxLevel);
				Assert.assertEquals(user.map[item.x + "_" + item.y] == null, item.level == item.maxLevel);
			}
			Assert.assertEquals(user.numItems, 2);
			Assert.assertEquals(user.numInventoryItems, 4);
			for (id in user.inventory) {
				Assert.assertFalse(user.collectItem(id));
			}
			Assert.assertEquals(user.numInventoryItems, 4);
		}
	}
}