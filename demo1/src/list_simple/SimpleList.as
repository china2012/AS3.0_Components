package list_simple
{
	import fl.controls.ScrollBarDirection;
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
		private var _container:Sprite;
		private var _containerMask:Sprite;
		private var _renderers:Vector.<SimpleRenderer>;
		private var _renderersSort:Vector.<SimpleRenderer>;
		// use majicion when you change the scrollX or scrollY and dataprovider.lenght > container's maxcount
		// at container, # is majicion and * is renderer of dataproviders
		/**If _direction==ScrollBarDirection.VERTICAL*/
		//   # # # # # # # #
		//   * * * * * * * *
		//   * * * * * * * *
		//   * * * * * * * *
		//   * * * * * * * *
		//   # # # # # # # #
		/**Else If _direction==ScrollBarDirection.HORIZONTAL*/
		// # * * * * * * * * #
		// # * * * * * * * * #
		// # * * * * * * * * #
		// # * * * * * * * * #
		private var _renderersMagician:Vector.<SimpleRenderer>;
		
		// default value
		private var default_rowWidth:Number = 125;
		private var default_rowHeight:Number = 125;
		private var default_rowCount:uint = 4;
		private var default_columnCount:uint = 3;
		private var default_renderer:Class = ImageCell;
		
		private var _direction:String;
		
		public function SimpleList()
		{
			_renderers = new Vector.<SimpleRenderer>();
			_renderersMagician = new Vector.<SimpleRenderer>();
			_renderersSort = new Vector.<SimpleRenderer>();
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
			_columnCount = default_columnCount;
			_direction = ScrollBarDirection.VERTICAL;
			refreshAll();
			
			_lastStartIndex = startIndex;
			_lastEndIndex = endIndex;
		}
		
		////////////////////////////////////////////////////////////////
		// Internal Logic
		/**
		 * public function refreshAll():void
		 * private function refreshContainerMask():void
		 * private function refreshAllRendererPosition():void
		 * private function refreshRendererPosition(index:uint):void
		 * private function refreshAllRendererInstance():void
		 * private function refreshRenderersLength():void
		 * private function refreshRendererData(index:int):void
		 * private function refreshMajicionLength():void
		 * private function refreshScrollDirection():void
		 * */
		private function refreshContainerMask():void
		{
			var maxWidth:Number = rowWidth * columnCount;
			var maxHeight:Number = rowHeight * rowCount;
			_containerMask.graphics.clear();
			_containerMask.graphics.beginFill(0);
			_containerMask.graphics.drawRect(0, 0, maxWidth, maxHeight);
			_containerMask.graphics.endFill();
			trace("refreshContainerMask =>(maxWidth:"+maxWidth+",maxHeight:"+maxHeight+")");
		}
		
		private function refreshAllRendererPosition():void
		{
			for (var i:int=0; i<_renderers.length; i++)
				refreshRendererPosition(i);
			trace("refreshAllRendererPosition");
		}
		
		private function refreshRendererPosition(index:uint):void
		{
			var d:SimpleRenderer = _renderers[index];
			var rowAt:int = getRowAt(index);
			var columnAt:int = getColumnAt(index);
			
			d.x = columnAt * rowWidth;
			d.y = rowAt * rowHeight;
			trace("refreshRendererPosition["+index+"] position(line="+rowAt+",columu="+columnAt+")");
		}
		
		// when your set the renderer And set's value not like last set _renderer
		private function refreshAllRendererInstance():void
		{
			for (var i:int=0; i<_renderers.length; i++)
			{
				var d:SimpleRenderer = new renderer();
				d.y = i * rowHeight;
				_container.addChild(d);
				_renderers[i] = d;
			}
			trace("refreshAllRendererInstance");
		}
		
		private function refreshRenderersLength():void
		{
			var maxChilderNum:uint = rowCount * columnCount;
			if (maxChilderNum > _renderers.length)
			{
				// need addChild renderer and update renderer.data
				while (maxChilderNum > _renderers.length)
				{
					var index:int = _renderers.push( new renderer() ) -1;
					_container.addChild(_renderers[index]);
					refreshRendererPosition(index);
					refreshRendererData(index);
				}
			}
			else if (maxChilderNum < _renderers.length)
			{
				// need removeChild renderer
				while (maxChilderNum < _renderers.length )
				{
					_container.removeChild(_renderers[_renderers.length -1]);
					_renderers.pop();
				}
			}
			trace("refreshRenderersLength");
		}
		
		private function refreshRendererData(index:int):void
		{
			_renderers[index].data = _dataProvider.getItemAt(index);
			trace("refreshRendererData["+index+"]");
		}
		
		public function refreshAll():void
		{
			refreshAllRendererPosition();
			refreshAllRendererInstance();
			refreshContainerMask();
			trace("refreshAll");
		}
		
		private function refreshMajicionLength():void
		{
			var num:uint = _direction == ScrollBarDirection.VERTICAL ? columnCount * 2:rowCount * 2;
			while (num != _renderersMagician.length)
			{
				if (num > _renderersMagician.length)
				{
					_renderersMagician.push( new renderer() );
				}
				else if (num < _renderersMagician.length)
				{
					if (_renderersMagician[0].parent)
						_renderersMagician[0].parent.removeChild(_renderersMagician[0]);
					_renderersMagician.splice(0,1);
				}
			}
			trace("refreshMajicionLenght => length:"+_renderersMagician.length+"");
		}
		
		private function refreshScrollDirection():void
		{
			refreshMajicionLength();
			trace("refreshScrollDirection");
		}
		
		private function refreshRenderersSortContent():void
		{
			_renderersSort.splice(0, _renderersSort.length);
			for (var topIndex:int=0; topIndex<_columnCount; topIndex++)
				_renderersSort.push( _renderersMagician[topIndex] );
			
			for (var middleIndex:int=0; middleIndex<_renderers.length; middleIndex++)
				_renderersSort.push( _renderers[middleIndex] );
			
			for (var bottomIndex:int=0; bottomIndex<_columnCount; bottomIndex++)
				_renderersSort.push( _renderersMagician[topIndex + bottomIndex] );
			trace("refreshRenderersSortContent");
		}
		
		//====some get and set
		private function getColumnAt(index:int):int
		{
			return index % columnCount;
		}
		
		private function getRowAt(index:int):int
		{
			return index / columnCount;
		}
		
		private function get startIndex():int
		{
			if (_direction == ScrollBarDirection.HORIZONTAL)
			{
				
			}
			else
			{
				var verticalStartIndex:Number = -(_container.y - _containerMask.y) / rowHeight;
				if (verticalStartIndex < 0)
					return 0;
				else if (verticalStartIndex > 0)
					return int(verticalStartIndex) * columnCount;
				else if (verticalStartIndex == 0)
					return 0;
			}
			return -1;
		}
		
		private function get endIndex():int
		{
			if (_direction == ScrollBarDirection.HORIZONTAL)
			{
				
			}
			else
			{
				var verticalStartIndex:Number = -(_container.y - _containerMask.y) / rowHeight;
				var verticalEndIndex:int = startIndex + rowCount * columnCount + columnCount;
				verticalEndIndex -= 1;
				if (verticalStartIndex is int)
					verticalEndIndex -= columnCount;
				if (verticalEndIndex > dataProvider.length)
					verticalEndIndex = dataProvider.length-1;
				
				return verticalEndIndex;
			}
			return -1;
		}
		
		////////////////////////////////////////////////////////////////
		// on list config change
		/**
		 * private function onRowCountChange():void
		 * private function onColumnCountChange():void
		 * private function onRowHeightChange():void
		 * private function onRowWidthChange():void
		 * private function onRendererInstanceChange():void
		 * protected function onDataProviderChange(event:DataChangeEvent):void
		 * private function onScrollYChange():void
		 * private function onScrollXChange():void
		 * private function onScrollDirection():void
		 */
		private function onRowCountChange():void
		{
			refreshContainerMask();
			refreshRenderersLength();
			refreshMajicionLength();
			refreshRenderersSortContent();
		}
		
		private function onColumnCountChange():void
		{
			refreshAllRendererPosition();
			refreshMajicionLength();
			refreshRenderersSortContent();
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
		
		private function onRendererInstanceChange():void
		{
			refreshAllRendererInstance();
			refreshMajicionLength();
			refreshRenderersSortContent();
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
//						if (index < rowCount * columnCount)
						{
							if (_renderers.length <= index){
								d = new renderer();
								_container.addChild(d);
								_renderers[index] = d;
							}
							refreshRendererData(index);
							refreshRendererPosition(index);
							refreshRenderersSortContent();
						}
					}
					break;
				}
				case DataChangeType.CHANGE:
				{
					trace("DataChangeType.CHANGE");
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
		
		// ==============================================================================
		private var _lastStartIndex:int;
		private var _lastEndIndex:int;
		// ==============================================================================
		private function onScrollYChange():void
		{
			if (_direction != ScrollBarDirection.VERTICAL)
				return;
			
			trace("==the current("+startIndex+","+endIndex+") list data has:");
			
			if (_lastStartIndex != startIndex || _lastEndIndex != endIndex)
			{
//				_lastStartIndex = startIndex;
//				_lastEndIndex = endIndex;
				// add renderer for  _tempYRollRenderers --sort
				
				
				// set renderer data
//				for (var i:int=0; i<_renderersSort.length; i++)
//				{
//					var dpIndex:int = startIndex + i;
//					_renderersSort[i].data = _dataProvider.getItemAt(dpIndex);
//				}
			}
		}
		
		private function onScrollXChange():void
		{
			if (_direction != ScrollBarDirection.HORIZONTAL)
				return;
		}
		
		private function onScrollDirection():void
		{
			refreshScrollDirection();
			refreshRenderersSortContent();
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
				onRendererInstanceChange();
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
			onColumnCountChange();
		}
		
		public function get columnCount():uint
		{
			return _columnCount;
		}
		
		public function set direction(value:String):void
		{
			if (_direction == value)
				return;
			
			if (value == ScrollBarDirection.VERTICAL)
				_direction = ScrollBarDirection.VERTICAL;
			else
				_direction = ScrollBarDirection.HORIZONTAL;
			
			onScrollDirection();
		}
		
		public function get direction():String
		{
			return _direction;
		}
		
		public function set scrollX(value:Number):void
		{
			if (_container.x != value)
			{
				_container.x = value;
				onScrollXChange();
			}
		}
		
		public function get scrollX():Number
		{
			return _container.x;
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