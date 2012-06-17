package list_simple
{
	import flash.display.Sprite;
	import list_simple.interfaces.IRenderer;

	public class SimpleRenderer extends Sprite implements IRenderer
	{
		private var _id:int;
		private var _data:Object;
		private var _selected:Boolean;
		
		public function SimpleRenderer()
		{
			
		}
		
		////////////////////////////////////////////////////////////////
		// on list config change
		private function refreshView():void
		{
			
		}
		
		private function refreshSelected():void
		{
			
		}
		
		////////////////////////////////////////////////////////////////
		// in implement function
		public function set data(value:Object):void
		{
			_data = value;
			refreshView();
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set id(value:int):void
		{
			_id = value;
		}
		
		public function get id():int
		{
			return 0;
		}
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
			refreshSelected();
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
	}
}