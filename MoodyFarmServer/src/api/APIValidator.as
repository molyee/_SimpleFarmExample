package api
{
	import models.User;
	
	/**
	 * { В новой версии не используется }
	 * 
	 * Класс валидации данных, передаваемых клиентом при вызове
	 * серверных методов
	 * ...
	 * @author Alex Sarapulov
	 */	
	public class APIValidator
	{
		/**
		 * Конструктор класса валидатора
		 * 
		 */		
		public function APIValidator()
		{
		}
		
		/**
		 * Проверка прав пользователя (простая версия проверяет права
		 * лишь на основе данных об авторизованности пользователя)
		 * 
		 * @param user Объект пользователя
		 * @param logged 
		 * @return 
		 * 
		 */		
		public function checkPermissions(user:User, logged:Boolean = true):Boolean
		{
			return user.logged;
		}
	}
}