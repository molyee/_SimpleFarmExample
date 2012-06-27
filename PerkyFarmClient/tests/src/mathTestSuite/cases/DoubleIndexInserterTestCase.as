package mathTestSuite.cases
{
	import flexunit.framework.Assert;
	
	import math.DoubleIndexInserter;
	
	public class DoubleIndexInserterTestCase
	{
		private var inserters:Array = new Array(3);
		
		[Before]
		public function setUp():void
		{
			inserters[0] = new DoubleIndexInserter(0, 100, 'v', 10);
			inserters[1] = new DoubleIndexInserter(-1, 116, 'v', 13);
			inserters[2] = new DoubleIndexInserter(0, 100, 'v', 9);
		}
		
		[After]
		public function tearDown():void
		{
			inserters = null;
		}
		
		[Test(order=1)]
		public function testDoubleIndexInserter():void
		{
			for each (var inserter:DoubleIndexInserter in inserters) {
				var start:* = inserter.paths.start;
				var end:* = inserter.paths.end;
				Assert.assertNotNull(start);
				Assert.assertNotNull(end);
				var counter:int = 0;
				for (var id:* in inserter.paths) {
					counter++;
				}
				Assert.assertEquals(inserter.numPaths + 2, counter);
				var last_id:*;
				id = "start";
				while (id != "end") {
					last_id = id;
					id = inserter.nextPathIDs[id];
					if (id is String || last_id is String) {
						Assert.assertTrue(id is String && !(last_id is String) ||
										  !(id is String) && last_id is String);
						continue;
					}
					Assert.assertTrue(int(last_id) < int(id));
				}
			}
		}
		
		[Test(order=2)]
		public function testInsert():void
		{
			var l:Array = [];
			var n:int = 100;
			var min:int = -20;
			var max:int = 150;
			for (var i:int = 0; i < 100; i++) {
				var v:int = Math.random() * (max - min) + min;
				l[i] = {v: v};
			}
			var inserter:DoubleIndexInserter = inserters[0] as DoubleIndexInserter;
			for each (var data:* in l) {
				inserter.insert(data);
			}
			Assert.assertEquals(l.lenght, inserter.indexes.length);
			var indexes:Array = inserter.indexes;
			var lastv:int = -int.MIN_VALUE;
			for (i = 0; i < indexes.length; i++) {
				v = indexes[i]['v'];
				Assert.assertTrue(v > lastv);
				lastv = v;
			}
		}
		
		[Test(order=3)]
		public function testRemove():void
		{
			Assert.fail("Test method Not yet implemented");
		}
	}
}