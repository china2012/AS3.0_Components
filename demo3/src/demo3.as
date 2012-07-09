package
{
	import com.sloader.SLoader;
	import com.sloader.SLoaderEventType;
	import com.sloader.SLoaderError;
	import com.sloader.SLoaderFile;
	import com.sloader.SLoaderInfo;
	
	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.system.SecurityDomain;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class demo3 extends Sprite
	{
		private var sloader:SLoader;
		private var textField:TextField;
		
		public function demo3()
		{
			textField = new TextField();
			textField.x = 100;
			textField.y = 100;
			addChild(textField);
			
			sloader = new SLoader();
			sloader.addEventListener(SLoaderEventType.SLOADER_COMPLETE, onConfigDataComplete);
			
			var fileVO:SLoaderFile = new SLoaderFile();
			fileVO.name = "config";
			fileVO.title = "config";
			fileVO.url = "NewFile.xml";
			fileVO.version = "1asdasd";
			sloader.addFile(fileVO);
			sloader.execute();
		}
		
		private function onConfigDataComplete(loadInfo:SLoaderInfo=null):void
		{
				sloader.removeEventListener(SLoaderEventType.SLOADER_COMPLETE, onConfigDataComplete);
				var configFile:SLoaderFile = sloader.getFileVO("config");
				var config:XML = new XML((configFile.loaderInfo.loader as URLLoader).data);
				
				var files:Array = [];
				for each(var item:XML in config.files.item)
				{
					var fileVO:SLoaderFile = new SLoaderFile();
					fileVO.name = String(Math.random() * Math.random());
					fileVO.title = String(Math.random() * Math.random());
					fileVO.url = item.@url;
					fileVO.version = "0.0.1";
					files.push(fileVO);
				}
				
//				sloader.addEventListener(SLoaderEventType.FILE_START, onFileStart);
//				sloader.addEventListener(SLoaderEventType.FILE_PROGRESS, onFileProgress);
//				sloader.addEventListener(SLoaderEventType.FILE_COMPLETE, onFileComplete);
				
//				sloader.addEventListener(SLoaderEventType.SLOADER_START, onSloaderStart);
				sloader.addEventListener(SLoaderEventType.SLOADER_PROGRESS, onSloaderProgress);
//				sloader.addEventListener(SLoaderEventType.SLOADER_COMPLETE, onSloaderComplete);
				
				sloader.addFiles(files);
				sloader.execute();
		}
		
		private function onFileStart(fileVO:SLoaderFile):void
		{
			trace(fileVO.name + "开始加载");
		}
		
		private function onFileProgress(fileVO:SLoaderFile):void
		{
			trace("(demo)"+fileVO.loaderInfo.loadedBytes);
		}
		
		private function onFileComplete(fileVO:SLoaderFile):void
		{
			trace(fileVO.name + "加载完成");
		}
		
		private function onSloaderProgress(loadInfo:SLoaderInfo):void
		{
			textField.text = (loadInfo.currLoadedBytes/1024)+"kb";
//			trace("Sloader累计加载("+loadInfo.currLoadedBytes+")");
		}
		
		private function onSloaderComplete(loadInfo:SLoaderInfo):void
		{
			trace("文件全部加载完毕" 
				+ "\n本次加载数据:"+ loadInfo.currLoadedBytes
				+ "\nSloader累计加载数据:" + loadInfo.loadedBytes
			);
		}
	}
}