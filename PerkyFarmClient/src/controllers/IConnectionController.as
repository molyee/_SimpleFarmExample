package controllers 
{
	import flash.events.IEventDispatcher;
	import net.connection.Client;
	
	/**
	 * ...
	 * @author alex
	 */
	public interface IConnectionController extends IEventDispatcher
	{
		// свойство доступности
		function get inited():Boolean;
		
		// вызов метода 
		function call(client:Client, method:String, data:Object, callback:Function):void;
	}
	
}