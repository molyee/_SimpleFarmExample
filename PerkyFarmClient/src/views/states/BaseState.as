package views.states
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	
	/**
	 * Базовый класс визуального состояния объекта, ролью которого является
	 * создание списка подобъектов, которые должны быть включены в список 
	 * отображения родительского контейнера при вызове показа состояния и скрыты
	 * при необходимости в любой момент
	 * 
	 * @author Alex Sarapulov
	 * 
	 */	
	public class BaseState extends EventDispatcher implements IBaseState
	{
		protected var _stateID:String;
		/**
		 * Идентификатор состояния (имя)
		 * 
		 * @return 
		 * 
		 */		
		public function get stateID():String { return _stateID; }
		
		/**
		 * Ссылка на внешний контейнер
		 * @private
		 */		
		protected var _holder:DisplayObjectContainer;
		
		/**
		 * Объекты включенные в состояние
		 * @private
		 */		
		protected var _inners:Vector.<DisplayObject>;
		
		protected var _selected:Boolean;
		/**
		 * Триггер включения состояния
		 * 
		 * @return 
		 * 
		 */		
		public function get selected():Boolean { return _selected; }
		
		/**
		 * Конструктор класса состояния
		 * 
		 * @param stateID Идентификатор (наименование) состояния
		 * @param holder Родительский контейнер
		 * @param inners Визуальные объекты, включенные в список объектов
		 * состояния
		 * 
		 */		
		public function BaseState(stateID:String, holder:DisplayObjectContainer, inners:Vector.<DisplayObject>)
		{
			_holder = holder;
			_inners = inners;
			_stateID = stateID;
		}
		
		/**
		 * Подключение (selected = true) или отключение (selected = false) состояния
		 * 
		 * @param selected Флаг включения состояния
		 * 
		 */		
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
		
		/**
		 * Абстрактный метод запуска активности состояния
		 * 
		 */		
		public function start():void
		{
			throw("BaseState class method start() must be overrided");
		}
		
		/**
		 * Абстрактный метод остановки активности состояния
		 * 
		 */		
		public function stop():void
		{
			throw("BaseState class method stop() must be overrided");
		}
		
		/**
		 * Абстрактный обработчик изменения внешнего контейнера (или stage),
		 * для обновления позиции и размера вхождения
		 * 
		 * @param width Ширина родительского контейнера
		 * @param height Высота родительского контейнера
		 * 
		 */		
		public function resize(width:Number, height:Number):void
		{
			throw("BaseState class method resize(width:Number, height:Number) must be overrided");
		}
	}
}