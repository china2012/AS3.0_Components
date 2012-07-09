package com.sloader
{
	import com.sloader.loadhandlers.DAT_LoadHandler;
	import com.sloader.loadhandlers.Image_LoadHandler;
	import com.sloader.loadhandlers.LoadHandler;
	import com.sloader.loadhandlers.SWF_LoadHandler;
	import com.sloader.loadhandlers.XML_LoadHandler;
	
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	public class SLoader
	{
		private var _appDomain:ApplicationDomain;
		
		private var _loadHandlers:Array;
		private var _eventHandlers:Dictionary;
		
		private var _alreadyLoadFiles:Array;
		private var _readyLoadList:Array;
		private var _tempErrorFileList:Array;
		
		private var _readyLoadCount:int;
		private var _loadedFileCount:int;
		private var _readyLoadBytes:Number;
		private var _loadedBytes:Number;
		
//		private var _sloadInfo:SLoaderInfo;
//		private var _maxConcurrent:uint = 3;
		private var _isLoading:Boolean = false;
		
		private var _preLoadedBytes:Number = 0;
		
//		private static var _instance:SLoader;
		
		public function SLoader(name:String, applicationDomain:ApplicationDomain=null)
		{
//			if (_instance)
//				throw new Error("Sloader is single class");
			SLoaderManage.addSLoader(name, this);
			
			_appDomain = applicationDomain || new ApplicationDomain(ApplicationDomain.currentDomain);
			
			_eventHandlers = new Dictionary();
			_loadHandlers = [];
			_tempAlreadyLoadList = [];
			_alreadyLoadFiles = [];
			_readyLoadList = [];
			_tempErrorFileList = [];
			_sloadInfo = new SLoaderInfo();
			
			registerLoadHandler();
			registerEventHandler();
		}
		
//		public static function getInstance():SLoader
//		{
//			if (!_instance)
//				_instance = new SLoader();
//			return _instance;
//		}
		
		private function registerLoadHandler():void
		{
			_loadHandlers[SLoaderFileType.SWF.toLowerCase()] = SWF_LoadHandler;
			_loadHandlers[SLoaderFileType.XML.toLowerCase()] = XML_LoadHandler;
			_loadHandlers[SLoaderFileType.DAT.toLowerCase()] = DAT_LoadHandler;
			_loadHandlers[SLoaderFileType.JPG.toLowerCase()] = Image_LoadHandler;
			_loadHandlers[SLoaderFileType.PNG.toLowerCase()] = Image_LoadHandler;
			_loadHandlers[SLoaderFileType.BMP.toLowerCase()] = Image_LoadHandler;
		}
		
		private function registerEventHandler():void
		{
			_eventHandlers[SLoaderEventType.FILE_COMPLETE] = [];
			_eventHandlers[SLoaderEventType.FILE_ERROR] =  [];
			_eventHandlers[SLoaderEventType.FILE_PROGRESS] = [];
			_eventHandlers[SLoaderEventType.FILE_START] = [];
			_eventHandlers[SLoaderEventType.SLOADER_COMPLETE] = [];
			_eventHandlers[SLoaderEventType.SLOADER_PROGRESS] = [];
			_eventHandlers[SLoaderEventType.SLOADER_START] = [];
		}
		
		///////////////////////////////////////////////////////////////////////////
		// loadListManage
		///////////////////////////////////////////////////////////////////////////
		public function addFile(fileVO:SLoaderFile):void
		{
			checkIsLoading();
			checkFileVO(fileVO);
			checkRepeatVO(fileVO);
			
			_readyLoadList.push(fileVO);
		}
		
		public function addFiles(files:Array):void
		{
			checkIsLoading();
			
			for (var i:int=0; i<files.length; i++)
			{
				var fileVO:SLoaderFile = files[i];
				checkFileVO(fileVO);
				checkRepeatVO(fileVO);
				
				_readyLoadList.push(fileVO);
			}
		}
		
		public function removeFile(fileVO:SLoaderFile):void
		{
			checkIsLoading();
			
			var index:int = _readyLoadList.indexOf(fileVO);
			if (index != -1)
				_readyLoadList.splice(index, 1);
		}
		
		public function execute():void
		{
			checkIsLoading();
			if (_readyLoadList.length < 1)
				return;

			_execute();
		}
		
		private function _execute():void
		{
			var fileVO:SLoaderFile = _readyLoadList[0];
			var fileType:String = getFileType(fileVO).toLowerCase();
			var fileLoadHandlerClass:Class = _loadHandlers[fileType];
			if (!fileLoadHandlerClass)
			{
				throw new Error("you not registered handler on ["+fileType+"]");
			}
			else
			{
				_isLoading = true;
				var loadHandler:LoadHandler = new fileLoadHandlerClass(fileVO, _appDomain);
				loadHandler.setFileCompleteEventHandler(onFileComplete);
				loadHandler.setFileProgressEventHandler(onFileProgress);
				loadHandler.setFileStartEventHandler(onFileStart);
				loadHandler.setFileIoErrorEventHandler(onFileIoError);
				loadHandler.load();
			}
		}
		
		///////////////////////////////////////////////////////////////////////////
		// eventManage
		///////////////////////////////////////////////////////////////////////////
		public function addEventListener(type:String, handler:Function):void
		{
			if (!_eventHandlers[type])
				throw new Error("event name["+type+"] is Invalid");
			
			_eventHandlers[type].push(handler);
		}
		
		public function removeEventListener(type:String, handler:Function):void
		{
			if (!_eventHandlers[type])
				return;
			
			var index:int = (_eventHandlers[type] as Array).indexOf(handler);
			if (index != -1)
				_eventHandlers[type].splice(index, 1);
		}
		
		private function onFileStart(fileVO:SLoaderFile):void
		{
			_preLoadedBytes = 0;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_START], fileVO);
			
			if (_sloadInfo.currLoadedFileCount == _tempAlreadyLoadList.length)
				onSloaderStart(fileVO);
		}
		
		private function onFileProgress(fileVO:SLoaderFile):void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_PROGRESS], fileVO);
			onSloaderProgress(fileVO);
		}
		
		private function onFileComplete(fileVO:SLoaderFile):void
		{
			var index:int;
			index = _readyLoadList.indexOf(fileVO);
			if (index != -1)
			{
				_alreadyLoadFiles.push(_readyLoadList[index]);
				_tempAlreadyLoadList.push(_readyLoadList[index]);
				_readyLoadList.splice(index, 1);
			}
			
			var hasfile:Boolean = _readyLoadList.length > 0;
			_isLoading = hasfile;
			
			_sloadInfo.currLoadedFileCount++;
			_sloadInfo.loadedFileCount++;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_COMPLETE], fileVO);
			
			if (hasfile)
				_execute();
			else
				onSloaderComplete(fileVO);
		}
		
		private function onFileIoError(error:SLoaderError):void
		{
			var index:int = _readyLoadList.indexOf(error.file);
			if (index != -1)
			{
				_tempErrorFileList.push(_readyLoadList[index]);
				_readyLoadList.splice(index, 1);
			}
			
			var hasfile:Boolean = _readyLoadList.length > 0;
			_isLoading = hasfile;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_ERROR], error);
			
			if (hasfile)
				_execute();
			else
				onSloaderComplete(error.file);
		}
		
		private function onSloaderStart(currFileVO:SLoaderFile):void
		{
			for each(var fileVO:SLoaderFile in _readyLoadList)
			{
				if (isNaN(fileVO.totalBytes))
				{
					_sloadInfo.currTotalBytes = Number.NaN;
					break;
				}
				else
					_sloadInfo.currTotalBytes += fileVO.totalBytes;
			}
			
			_sloadInfo.currLoadedBytes = 0;
			_sloadInfo.currLoadedFileCount = 0;
			_sloadInfo.currTotalFileCount = _readyLoadList.length;
			_tempAlreadyLoadList.length = 0;
			_tempErrorFileList.length = 0;
			trace("开始加载"+currFileVO.name);
			
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_START], _sloadInfo);
		}
		
		private function onSloaderProgress(currFileVO:SLoaderFile):void
		{
			_preLoadedBytes = currFileVO.loaderInfo.loadedBytes - _preLoadedBytes;
			_sloadInfo.currLoadedBytes += _preLoadedBytes;
			_sloadInfo.loadedBytes += _preLoadedBytes;
			if (isNaN(_sloadInfo.currTotalBytes))
			{
				_sloadInfo.percentage = _sloadInfo.currLoadedFileCount/_sloadInfo.currTotalFileCount
					+ currFileVO.loaderInfo.loadedBytes/currFileVO.loaderInfo.totalBytes/_sloadInfo.currTotalFileCount;
			}
			else
			{
				_sloadInfo.percentage = _sloadInfo.currLoadedBytes/_sloadInfo.currTotalBytes;
			}
			_preLoadedBytes = currFileVO.loaderInfo.loadedBytes;
			
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_PROGRESS], _sloadInfo);
		}
		
		private function onSloaderComplete(currFileVO:SLoaderFile):void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_COMPLETE], _sloadInfo);
		}
		
		private function executeHandlers(handlers:Array, file:*):void
		{
			for (var i:int=0; i<handlers.length; i++)
			{
				var handler:Function = handlers[i];
				handler(file);
			}
		}
		
		///////////////////////////////////////////////////////////////////////////
		public function getFileType(file:SLoaderFile):String
		{
			if (file.type)
				return file.type;
			else{
				var extensions:Array = file.url.match(/[^\.][^\.]*/g);
				if (extensions)
				{
					if (extensions.length > 0)
					{
						var fileType:String = extensions[extensions.length-1];
						for (var _fileType:* in _loadHandlers)
						{
							if (_fileType == fileType)
								return _fileType;
						}
					}
				}
			}
			return "swf";
		}
		
		public function getFileVO(fileTitle:String):SLoaderFile
		{
			if (!_alreadyLoadFiles)
				return null;
			
			for each(var fileVO:SLoaderFile in _alreadyLoadFiles)
			{
				if (fileVO.title == fileTitle)
					return fileVO;
			}
			return null;
		}
		
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
		
		public function get loadInfo():SLoaderInfo
		{
			return _sloadInfo;
		}
		
		private function checkIsLoading():void
		{
			if (_isLoading)
				throw new Error("Refused the operation, is loaded in");
		}
		
		private function checkFileVO(fileVO:SLoaderFile):void
		{
			if (!fileVO.name || !fileVO.url || !fileVO.title)
				throw new Error("The fileVO parameter is incorrect");
		}
		
		private function checkRepeatVO(fileVO:SLoaderFile):void
		{
			for (var i:int=0; i<_tempAlreadyLoadList.length; i++)
			{
				if ((_tempAlreadyLoadList[i] as SLoaderFile).title == fileVO.title)
					throw new Error("Duplication of add file(title:"+fileVO.title+")");
			}
		}
	}
}