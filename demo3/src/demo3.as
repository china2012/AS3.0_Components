package
{
	import com.sloader.SLoader;
	import com.sloader.define.SLoaderEventType;
	import com.sloader.vo.SLoaderFileErrorVO;
	import com.sloader.vo.SLoaderFileVO;
	
	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.system.SecurityDomain;
	import flash.utils.setTimeout;
	
	public class demo3 extends Sprite
	{
		private var sloader:SLoader;
		
		public function demo3()
		{
			sloader = new SLoader();
			sloader.addEventListener(SLoaderEventType.FILE_COMPLETE, onConfigDataComplete);
			
			var fileVO:SLoaderFileVO = new SLoaderFileVO();
			fileVO.name = "config";
			fileVO.title = "config";
			fileVO.url = "NewFile.xml";
			sloader.addFile(fileVO);
			sloader.execute();
		}
		
		private function onConfigDataComplete(file:SLoaderFileVO):void
		{
				sloader.removeEventListener(SLoaderEventType.FILE_COMPLETE, onConfigDataComplete);
				var config:XML = new XML((file.loaderInfo.loader as URLLoader).data);
				
				var files:Array = [];
				var i:int=0;
				for each(var item:XML in config.files.item)
				{
					var fileVO:SLoaderFileVO = new SLoaderFileVO();
					fileVO.name = item.@name;
					fileVO.title = String(i++);
					fileVO.url = item.@url;
					files.push(fileVO);
				}
				sloader.addEventListener(SLoaderEventType.FILE_COMPLETE, onFileComplete);
				sloader.addEventListener(SLoaderEventType.FILE_ERROR, onFileError);
				sloader.addEventListener(SLoaderEventType.FILE_PROGRESS, onFileProgress)
				sloader.addFiles(files);
				
				sloader.execute();
		}
		
		private function onFileProgress(fileVO:SLoaderFileVO):void
		{
			trace("progress["+fileVO.name+"]--"+fileVO.loaderInfo.loadedBytes/fileVO.loaderInfo.totalBytes * 100+"%");
		}
		
		private function onFileComplete(fileVO:SLoaderFileVO):void
		{
			trace("complete["+fileVO.name+"]--"+fileVO.loaderInfo.loadedBytes/fileVO.loaderInfo.totalBytes * 100+"%");
		}
		
		private function onFileError(sloaderError:SLoaderFileErrorVO):void
		{
			trace(sloaderError.file.name+"["+sloaderError.desc+"]...");
		}
	}
}