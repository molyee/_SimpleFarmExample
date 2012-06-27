package errors
{
	public class UserError
	{
		public static const ACCESS_DENIED:int = 0;
		public static const METHOD_NOT_AVAILABLE:int = 1;
		public static const WRONG_ARGUMENTS:int = 2;
		
		public static const G_CALL_ABORTED:int = 3;
		
		
		public static const DESCRIPTIONS:Object = {
			0: "access denied",
			1: "server method is not available",
			2: "wrong arguments",
			3: "call aborted"
		}
		
		public static function getMessage(errorCode:int):String
		{
			var message:String = DESCRIPTIONS[errorCode];
			if (!message) message = "unhandled error";
			return message;
		}
		
		public static function getErrorData(errorCode:int):Object
		{
			var message:String = getMessage(errorCode);
			return { code: errorCode, message: message };
		}
	}
}