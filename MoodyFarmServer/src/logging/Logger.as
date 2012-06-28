package logging
{
	/**
	 * Класс контроллера логирования
	 * ...
	 * @author Alex Sarapulov
	 * 
	 */	
	public class Logger
	{
		/**
		 * Объект синглтон контроллера логирования
		 * 
		 */		
		public static const instance:Logger = new Logger();
		
		/**
		 * Обработчики добавления сообщений в лог
		 * @private
		 */		
		private var _handlers:Array = [];
		
		/**
		 * Конструктор класса контроллера логов
		 * 
		 */		
		public function Logger()
		{
			if (Logger) throw("Logger is singleton, constructor unavailable");
		}
		
		/**
		 * Добавление слушающего метода логирования
		 * 
		 * @param handler Обработчик
		 * 
		 */		
		public function addListener(handler:Function):void
		{
			_handlers.push(handler);
		}
		
		/**
		 * Удаление слушающего метода логирования
		 * 
		 * @param handler Обработчик
		 * 
		 */		
		public function removeListener(handler:Function):void
		{
			var index:int = _handlers.indexOf(handler);
			if (index == -1)
				return;
			_handlers.splice(index, 1);
		}
		
		/**
		 * Запись сообщения в лог
		 * 
		 * @param message Сообщение
		 * 
		 */		
		public function write(message:String):void
		{
			if (!message)
				return;
			for each (var handler:Function in _handlers) {
				handler(message);
			}
			trace(message);
		}
		
		/**
		 * Запись сообщения в лог с добавлением символа переноса строки
		 * 
		 * @param message Сообщение
		 * 
		 */		
		public function writeLine(message:String = null):void
		{
			if (!message)
				message = "";
			write(message + "\n");
		}
	}
}