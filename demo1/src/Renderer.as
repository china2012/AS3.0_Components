package
{
	import flash.display.Sprite;
	
	import list_simple.SimpleRenderer;
	
	public class Renderer extends SimpleRenderer
	{
		private const WIDTH:Number = 250;
		private const HEIGHT:Number = 125;
		
		public function Renderer()
		{
			super();
			draw();
		}
		
		private function draw():void
		{
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0xFFFFFF * Math.random());
			sp.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			sp.graphics.endFill();
			addChild(sp);
			
			for (var i:int=0; i<10; i++){
				var nsp:Sprite = new Sprite();
				nsp.graphics.beginFill(0xFFFFFF * Math.random());
				nsp.graphics.drawCircle(
					WIDTH * Math.random(),
					HEIGHT * Math.random(),
					HEIGHT * Math.random()/10
				);
				nsp.graphics.endFill();
				sp.addChild(nsp);
			}
		}
	}
}