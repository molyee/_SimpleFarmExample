package views.controls.buttons
{
	import display.controls.buttons.LabeledBaseButton;
	import display.utils.ColorMatrix;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author alex
	 */
	public class GLabeledButton extends LabeledBaseButton
	{
		protected static const DEFAULT_TEXT_FORMAT:TextFormat = new TextFormat("Calibri", 18, 0xffffff);
		
		protected static const ACTIVE_STATE_FILTERS:Array = [new GlowFilter(0x33cc00, 0.5, 10, 8, 2, 2)];
		protected static const DISABLED_STATE_FILTERS:Array = [new ColorMatrixFilter(ColorMatrix.BLACK_AND_WHITE)];
		protected static const DOWN_STATE_FILTERS:Array = [new ColorMatrixFilter(ColorMatrix.SEPIA)];		
		
		public function GLabeledButton(id:String, label:String, width:Number = 100, height:Number = 35) 
		{
			var bitmapData:BitmapData = new BitmapData(width, height, false, 0x33cc00);
			var background:Bitmap = new Bitmap(bitmapData);
			super(id, label, DEFAULT_TEXT_FORMAT, background, DISABLED_STATE_FILTERS, ACTIVE_STATE_FILTERS, DOWN_STATE_FILTERS, false);
		}
		
	}

}