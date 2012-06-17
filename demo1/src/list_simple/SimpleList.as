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
		private var _renderer:Class;
		private var _rowWidth:Number;
		private var _rowHeight:Number;
		private var _rowCount:uint;
		private var _columnCount:uint
		
		// don't know
		private var _renderers:Vector.<SimpleRenderer>;
		private var _container:Sprite;
		private var _containerMask:Sprite;
		
		// default value
		private var default_rowWidth:Number = 400;
		private var default_rowHeight:Number = 100;
		private var default_rowCount:uint = 3;
		private var default_columuCount:uint = 3;
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
			_renderer = default_renderer;
			_rowWidth = default_rowWidth;
			_rowHeight = default_rowHeight;
			_rowCount = default_rowCount;
			
			refreshAll();
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
			trace("refreshContainerMask");
		}
		
		private function refreshAllRendererPosition():void
		{
			var lineAt:uint;
			var columuAt:uint;
			for (var i:int=0; i<_renderers.length; i++)
			{
				_renderers[i].y = i * rowHeight;
				trace("renderer position(line="+lineAt+",columu="+columuAt+")");
			}
			trace("refreshAllRendererPosition");
		}
		
		// when your set the renderer And set's value not like last set _renderer
		private function refreshAllRendererInstance():void
		{
			for (var i:int=0; i<_renderers.length; i++)
			{
				var d:SimpleRenderer = new _renderer();
				d.y = i * rowHeight;
				_container.addChild(d);
				
				_renderers[i] = d;
			}
			trace("refreshAllRendererInstance");
		}
		
		private function refreshRendererData(index:int):void
		{
			_renderers[index].data = _dataProvider.getItemAt(index);
			trace("refreshRendererData");
		}
		
		public function refreshAll():void
		{
			refreshAllRendererPosition();
			refreshAllRendererInstance();
			refreshContainerMask();
			trace("refreshAll");
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
		
		private function onScrollYChange():void
		{
			// dataProvider.lenght > rowCount then use the 
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
			if (value != _renderer)
			{
				_renderer = value;
				refreshAllRendererInstance();
			}
		}
		
		public function get renderer():Class
		{
			return _renderer;
		}
		
		public function set rowWidth(value:Number):void
		{
			_rowWidth = value;
			onRowWidthChange();
		}
		
		public function get rowWidth():Number
		{
			return _rowWidth;
		}
		
		public function set rowHeight(value:Number):void
		{
			_rowHeight = value;
			onRowHeightChange();
		}
		
		public function get rowHeight():Number
		{
			return _rowHeight;
		}
		
		public function set rowCount(value:uint):void
		{
			_rowCount = value;
			onRowCountChange();
		}
		
		public function get rowCount():uint
		{
			return _rowCount;
		}
		
		public function set columnCount(value:uint):void
		{
			_columnCount = value;
			refreshAllRendererPosition();
		}
		
		public function get columnCount():uint
		{
			return _columnCount;
		}
		
		public function set scrollY(value:Number):void
		{
			if (_container.y != value)
			{
				_container.y = value;
				onScrollYChange();
			}
		}
		
		public function get scrollY():Number
		{
			return _container.y;
		}
	}
}