package com.sloader.vo
{
	public class SLoaderFileErrorVO
	{
		public var file:SLoaderFileVO;
		public var desc:String;
		
		public function SLoaderFileErrorVO(fileVO:SLoaderFileVO, descStr:String)
		{
			file = fileVO;
			desc = descStr;
		}
	}
}