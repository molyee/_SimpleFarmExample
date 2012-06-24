package controllers 
{
	import flash.events.IEventDispatcher;
	import models.Item;
	import net.connection.Client;
	
	/**
	 * ...
	 * @author alex
	 */
	public interface IConnectionController extends IEventDispatcher
	{
		// свойство доступности
		function get inited():Boolean;
		
		// получение ресурса
		function getResource(url:String, callback:Function):void;
		
		// получение данных о пользователе
		function getUserData(userID:String, callback:Function):void;
		
		// получение данных об объекте на карте пользователя
		function getItem(userID:String, itemID:String, callback:Function):Boolean;
		
		// получение данных о типе объекта
		function getItemTypeData(itemType:String, callback:Function):void;
		
		// получение данных о типах объектов
		function getItemTypes(callback:Function):void;
		
		// -- user api
		
		// создание объекта и установка в указанную точку
		function placeItem(client:Client, itemType:String, xpos:int, ypos:int, callback:Function):String;
		
		// перемещение объекта в указанную точку
		function moveItem(client:Client, itemID:String, xpos:int, ypos:int, callback:Function):Boolean;
		
		// сбор объекта с карты
		function collectItem(client:Client, itemID:String, callback:Function):Boolean;
		
		// повышение уровня объектов
		function upgradeItems(client:Client, itemIDs:Array, callback:Function):Array;
		
		
		// вызов метода 
		function call(client:Client, method:String, data:*, callback:Function):void;
	}
	
}