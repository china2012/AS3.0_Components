package
{
	import com.greensock.TweenLite;
	
	import fl.controls.Button;
	import fl.controls.TileList;
	import fl.data.DataProvider;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	
	import list_simple.SimpleList;
	
	public class demo1 extends Sprite
	{
		private var button1:Button;
		private var button2:Button;
		private var dataProvider:DataProvider;
		private var listSimple:SimpleList;
		
		public function demo1()
		{
			// set stage
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// show demo
			listSimple = new SimpleList();
			listSimple.renderer = Renderer;
			
			dataProvider = listSimple.dataProvider;
			for (var i:int=0; i<30; i++)
				dataProvider.addItem({name:i});

			addChild(listSimple);
			
			button1 = new Button();
			button1.x = 650;
			button1.label = "上";
			addChild(button1);
			button1.addEventListener(MouseEvent.CLICK, onMouseClickButton1);
			
			button2 = new Button();
			button2.x = 750;
			button2.label = "下";
			addChild(button2);
			button2.addEventListener(MouseEvent.CLICK, onMouseClickButton2);
		}
		
		protected function onMouseClickButton1(event:MouseEvent):void
		{
//			TweenLite.to(listSimple, 1, {y:listSimple.y-100});
			TweenLite.to(listSimple, 1, {scrollY:listSimple.scrollY-100});
		}
		
		protected function onMouseClickButton2(event:MouseEvent):void
		{
//			TweenLite.to(listSimple, 1, {y:listSimple.y+100});
			TweenLite.to(listSimple, 1, {scrollY:listSimple.scrollY+100});
		}
	}
}