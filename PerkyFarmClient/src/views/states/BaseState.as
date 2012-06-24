package views.states
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	
	public class BaseState extends EventDispatcher implements IBaseState
	{
		// идентификатор состояния (имя)
		protected var _stateID:String;
		public function get stateID():String { return _stateID; }
		
		// ссылка на внешний контейнер
		protected var _holder:DisplayObjectContainer;
		
		// объекты включенные в состояние
		// (могут пренадлежать нескольким состояниям, но отображаться только в одном)
		protected var _inners:Vector.<DisplayObject>;
		
		// триггер включения состояния
		protected var _selected:Boolean;
		public function get selected():Boolean { return _selected; }
		
		// -- конструктор
		public function BaseState(stateID:String, holder:DisplayObjectContainer, inners:Vector.<DisplayObject>)
		{
			_holder = holder;
			_inners = inners;
			_stateID = stateID;
		}
		
		// подключить(true)/отключить(false) состояние
		public function setSelection(selected:Boolean):void
		{
			if (_selected == selected) return;
			_selected = selected;
			var inner:DisplayObject;
			var n:int = _inners.length - 1;
			var i:int = n;
			for (i; i >= 0; i--) {
				inner = _inners[i];
				if (inner.parent)
					inner.parent.removeChild(inner);
				if (_selected)
					_holder.addChildAt(inner, 0);
			}
		}
		
		// запуск активности состояния
		public function start():void
		{
			throw("BaseState class method start() must be overrided");
		}
		
		// остановка активности состояния
		public function stop():void
		{
			throw("BaseState class method stop() must be overrided");
		}
		
		// обработчик изменения внешнего контейнера (или stage), для обновления позиции и размера вхождения
		public function resize(width:Number, height:Number):void
		{
			throw("BaseState class method resize(width:Number, height:Number) must be overrided");
		}
	}
}