package api
{
	import models.User;
	
	public class APIValidator
	{
		public function APIValidator()
		{
		}
		
		public function checkPermissions(user:User, logged:Boolean = true):Boolean
		{
			return user.logged;
		}
	}
}