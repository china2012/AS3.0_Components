package
{
	import fl.controls.TileList;
	import fl.data.DataProvider;
	
	import flash.display.Sprite;
	
	import list_simple.SimpleList;
	
	public class demo1 extends Sprite
	{
		public function demo1()
		{
			var listSimple:SimpleList = new SimpleList();
			listSimple.renderer = Renderer;
			
			var dataProvider:DataProvider = listSimple.dataProvider;
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			dataProvider.addItem({});
			listSimple.dataProvider = dataProvider;

			listSimple.rowHeight = 70;
//			listSimple.rowCount = 5;
			addChild(listSimple);
		}
	}
}