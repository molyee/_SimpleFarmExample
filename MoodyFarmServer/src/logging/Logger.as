package logging
{
	public class Logger
	{
		public static const instance:Logger = new Logger();
		
		private var _handlers:Array = [];
		
		public function Logger()
		{
			if (Logger) throw("Logger is singleton, constructor unavailable");
		}
		
		public function addListener(handler:Function):void
		{
			_handlers.push(handler);
		}
		
		public function removeListener(handler:Function):void
		{
			var index:int = _handlers.indexOf(handler);
			if (index == -1)
				return;
			_handlers.splice(index, 1);
		}
		
		public function write(message:String):void
		{
			if (!message)
				return;
			for each (var handler:Function in _handlers) {
				handler(message);
			}
			trace(message);
		}
		
		public function writeLine(message:String = null):void
		{
			if (!message)
				message = "";
			write(message + "\n");
		}
	}
}