package errors
{
	/**
	 * Класс данных об ошибках, возникающих при общении клиента
	 * с сервером
	 * 
	 * @author Alex Sarapulov
	 * 
	 */	
	public class UserError
	{
		// -- константы кодов ошибок
		
		public static const ACCESS_DENIED:int = 0;
		public static const METHOD_NOT_AVAILABLE:int = 1;
		public static const WRONG_ARGUMENTS:int = 2;
		public static const G_CALL_ABORTED:int = 3;
		
		
		/**
		 * Описания ошибки с доступом по коду ошибки
		 * 
		 */		
		public static const DESCRIPTIONS:Object = {
			0: "access denied",
			1: "server method is not available",
			2: "wrong arguments",
			3: "call aborted"
		}
		
		/**
		 * Получение описания ошибки по ее коду
		 * 
		 * @param errorCode Код ошибки
		 * @return Сообщение с описанием ошибки
		 * 
		 */			
		public static function getMessage(errorCode:int):String
		{
			var message:String = DESCRIPTIONS[errorCode];
			if (!message) message = "unhandled error";
			return message;
		}
		
		/**
		 * Получение данных ошибки
		 * 
		 * @param errorCode Код ошибки
		 * @return Полные данные об ошибке
		 * 
		 */		
		public static function getErrorData(errorCode:int):Object
		{
			var message:String = getMessage(errorCode);
			return { code: errorCode, message: message };
		}
	}
}