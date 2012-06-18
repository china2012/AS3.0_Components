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
		private var _renderers:Vector.<SimpleRenderer>;
		private var _tempXRollRenderers:Vector.<SimpleList>;
		private var _tempYRollRenderers:Vector.<SimpleList>;
		private var _container:Sprite;
		private var _containerMask:Sprite;
		
		// default value
		private var default_rowWidth:Number = 125;
		private var default_rowHeight:Number = 125;
		private var default_rowCount:uint = 4;
		private var default_columnCount:uint = 3;
		private var default_renderer:Class = ImageCell;
		
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
		private var _magicians:Vector.<SimpleRenderer>;
		private var _direction:String;
		
		public function SimpleList()
		{
			_renderers = new Vector.<SimpleRenderer>();
			_magicians = new Vector.<SimpleRenderer>();
			_tempXRollRenderers = new Vector.<SimpleList>();
			_tempYRollRenderers = new Vector.<SimpleList>();
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
			{
				refreshRendererPosition(i);
			}
			trace("refreshAllRendererPosition");
		}
		
		private function refreshRendererPosition(index:uint):void
		{
			var d:SimpleRenderer = _renderers[index];
			var rowAt:int = getRowAt(index);
			var columnAt:int = getColumuAt(index);
			
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
			var minMajicionNumber:uint;
			if (_direction == ScrollBarDirection.VERTICAL)
				minMajicionNumber = columnCount * 2;
			else
				minMajicionNumber = rowCount * 2;
			
			while (minMajicionNumber > _magicians.length)
				_magicians.push( new renderer() );

			trace("refreshMajicionLenght => length:"+_magicians.length+"");
		}
		
		private function refreshScrollDirection():void
		{
			refreshMajicionLength();
		}
		
		//====some get and set
		private function getColumuAt(index:int):int
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
				return -int((_container.y - _containerMask.y) / rowHeight) * columnCount;
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
				if (((_container.y - _containerMask.y) / rowHeight) is int)
					return startIndex + (rowCount - 1) * columnCount + 1;
				return startIndex + rowCount * columnCount +1;
			}
			return -1;
		}
		
		////////////////////////////////////////////////////////////////
		// on list config change
		private function onRowCountChange():void
		{
			refreshContainerMask();
			refreshRenderersLength();
			refreshMajicionLength();
		}
		
		private function onColumnCountChange():void
		{
			refreshAllRendererPosition();
			refreshMajicionLength();
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
						if (index < rowCount * columnCount)
						{
							if (_renderers.length <= index){
								d = new renderer();
								_container.addChild(d);
								_renderers[index] = d;
							}
							refreshRendererData(index);
							refreshRendererPosition(index);
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
		
		private function onScrollYChange():void
		{
			if (_direction != ScrollBarDirection.VERTICAL)
				return;
			trace("==the current("+startIndex+","+endIndex+") list data has:");
			
			// add renderer for  _tempXRollRenderers --sort
			
			// set renderer data
			
		}
		
		private function onScrollXChange():void
		{
			if (_direction != ScrollBarDirection.HORIZONTAL)
				return;
		}
		
		private function onScrollDirection():void
		{
			refreshScrollDirection();
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