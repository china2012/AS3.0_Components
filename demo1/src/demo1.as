package
{
	import fl.controls.TileList;
	import fl.data.DataProvider;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import list_simple.SimpleList;
	
	[swf(width="300")]
	public class demo1 extends Sprite
	{
		public function demo1()
		{
			// set stage
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// show demo
			var listSimple:SimpleList = new SimpleList();
			listSimple.renderer = Renderer;
			
			var dataProvider:DataProvider = listSimple.dataProvider;
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});

			addChild(listSimple);
		}
	}
}