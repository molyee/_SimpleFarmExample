package views.states
{
	import controllers.ClientConnectionController;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import models.Model;
	
	import views.map.MapView;
	import views.panels.GameControlPanel;
	
	[Event(name="complete", type="flash.events.Event")]
	public class GameState extends BaseState
	{
		private var _mapView:MapView;
		private var _controlPanel:GameControlPanel;
		
		private var _model:Model;
		private var _controller:ClientConnectionController;
		
		public function GameState(stateID:String, holder:DisplayObjectContainer, controller:ClientConnectionController)
		{
			_mapView = new MapView(controller, 30);
			_controlPanel = new GameControlPanel(controller);
			
			// создание списка активных объектов состояния
			var inners:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			inners.push(_mapView);
			inners.push(_controlPanel);
			
			// получение данных о контроллере
			_controller = controller;
			
			// создание модели
			_model = Model.instance;
			_model.addEventListener(Event.INIT, modelInitHandler);
			_model.init(_controller);
			
			_controller.getResource("/media/background.jpg", _mapView.setBackgroundTexture);
			
			super(stateID, holder, inners);
		}
		
		private function modelInitHandler(event:Event):void 
		{
			
		}
		
		override public function start():void
		{
			trace(_stateID + " started");
		}
		
		override public function stop():void
		{
			trace(_stateID + " stopped");
		}
		
		override public function resize(width:Number, height:Number):void
		{
			_mapView.resize(width, height);
			_controlPanel.resize(width, height);
		}
	}
}