package list_simple
{
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ImageCell;
	import fl.data.DataProvider;
	import fl.events.DataChangeEvent;
	import fl.events.DataChangeType;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;
	
	import list_simple.interfaces.IListSimple;
	
	public class SimpleList extends Sprite implements IListSimple
	{
		// know
		private var _dataProvider:DataProvider;
		private var _cellRenderer:Class;
		private var _rowWidth:Number;			// default is INT_DEFAULT
		private var _rowHeight:Number;			// default is INT_DEFAULT
		private var _rowCount:Number;			// default is INT_DEFAULT
		
		// don't know
		private var _renderers:Vector.<SimpleRenderer>;
		private var _container:Sprite;
		private var _containerMask:Sprite;
		
		// default value
		private const INT_DEFAULT:int = -9999;
		
		private var default_rowWidth:Number = 200;
		private var default_rowHeight:Number = 400;
		private var default_rowCount:Number = 2;
		private var default_renderer:Class = ImageCell;
		
		public function SimpleList()
		{
			_renderers = new Vector.<SimpleRenderer>();
			_container = new Sprite();
			_containerMask = new Sprite();
			_container.mask = _containerMask;
			addChild(_container);
			addChild(_containerMask);
			
			_dataProvider = new DataProvider();
			_dataProvider.addEventListener(DataChangeEvent.DATA_CHANGE, onDataProviderChange);
			
			initializeDefault();
		}
		
		
		////////////////////////////////////////////////////////////////
		// Some initialize's
		private function initializeDefault():void
		{
			_rowCount = INT_DEFAULT;
			_rowWidth = INT_DEFAULT;
			_rowHeight = INT_DEFAULT;
		}
		
		////////////////////////////////////////////////////////////////
		// Internal Logic
		private function refreshContainerMask():void
		{
			var maxWidth:Number = rowWidth;
			var maxHeight:Number = rowCount * rowHeight;
			_containerMask.graphics.clear();
			_containerMask.graphics.beginFill(0);
			_containerMask.graphics.drawRect(0, 0, maxWidth, maxHeight);
			_containerMask.graphics.endFill();
		}
		
		private function refreshAllRendererPosition():void
		{
			for (var i:int=0; i<_renderers.length; i++)
			{
				_renderers[i].y = i * rowHeight;
			}
		}
		
		private function refreshRendererData(index:int):void
		{
			_renderers[index].data = _dataProvider.getItemAt(index);
		}
		
		////////////////////////////////////////////////////////////////
		// on list config change
		private function onRowCountChange():void
		{
			refreshContainerMask();
		}
		
		private function onRowHeightChange():void
		{
			refreshContainerMask();
			refreshAllRendererPosition();
		}
		
		private function onRowWidthChange():void
		{
			refreshContainerMask();
		}
		
		protected function onDataProviderChange(event:DataChangeEvent):void
		{
			var i:int;
			var d:SimpleRenderer;
			var index:int;
			switch (event.changeType)
			{
				case DataChangeType.ADD:
				{
					for (i=0; i<event.items.length; i++){
						if (!event.items[i])
							continue;
						index = i + event.startIndex;
						if (_renderers.length <= index){
							d = new renderer();
							d.y = index * rowHeight;
							_container.addChild(d);
							_renderers[index] = d;
						}
						refreshRendererData(index);
					}
					break;
				}
				case DataChangeType.CHANGE:
				{
					break;
				}
				case DataChangeType.INVALIDATE:
				{
					break;
				}
				case DataChangeType.INVALIDATE_ALL:
				{
					break;
				}
				case DataChangeType.REMOVE:
				{
					break;
				}
				case DataChangeType.REMOVE_ALL:
				{
					break;
				}
				case DataChangeType.REPLACE:
				{
					break;
				}
				case DataChangeType.SORT:
				{
					break;
				}
			}
		}
		
		////////////////////////////////////////////////////////////////
		// in implement function
		public function set dataProvider(dp:DataProvider):void
		{
			_dataProvider = dp;
		}
		
		public function get dataProvider():DataProvider
		{
			return _dataProvider;
		}
		
		public function set renderer(value:Class):void
		{
			if (false)
			{
				throw new Error("the renderer must extends [rendererSimple]");
			}
			_cellRenderer = value;
		}
		
		public function get renderer():Class
		{
			if (!_cellRenderer)
				return default_renderer;
			return _cellRenderer;
		}
		
		public function set rowWidth(value:Number):void
		{
			_rowWidth = value;
			onRowWidthChange();
		}
		
		public function get rowWidth():Number
		{
			if (_rowWidth == INT_DEFAULT)
				return default_rowWidth;
			return _rowWidth;
		}
		
		public function set rowHeight(value:Number):void
		{
			_rowHeight = value;
			onRowHeightChange();
		}
		
		public function get rowHeight():Number
		{
			if (_rowHeight == INT_DEFAULT)
				return default_rowHeight;
			return _rowHeight;
		}
		
		public function set rowCount(value:uint):void
		{
			_rowCount = value;
			onRowCountChange();
		}
		
		public function get rowCount():uint
		{
			if (_rowCount == INT_DEFAULT)
				return default_rowCount;
			return _rowCount;
		}
		
		public function getRendererOfData(data:Object):SimpleRenderer
		{
			var len:uint = _renderers.length;
			for (var i:int=0; i<len; i++)
			{
				if (ICellRenderer(_renderers[i]).data == data)
					break;
			}
			return _renderers[i];
		}
	}
}