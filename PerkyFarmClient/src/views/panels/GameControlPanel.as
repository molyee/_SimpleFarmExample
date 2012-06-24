package views.panels
{
	import controllers.IConnectionController;
	import flash.display.Sprite;
	
	public class GameControlPanel extends Sprite
	{
		private var _controller:IConnectionController;
		
		public function GameControlPanel(controller:IConnectionController)
		{
			_controller = controller;
			
			super();
		}
		
		public function resize(width:Number, height:Number):void
		{
			
		}
	}
}