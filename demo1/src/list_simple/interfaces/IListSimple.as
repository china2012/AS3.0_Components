package list_simple.interfaces
{
	import fl.controls.listClasses.ICellRenderer;
	import fl.data.DataProvider;
	
	import flash.display.Sprite;
	
	import list_simple.SimpleRenderer;

	public interface IListSimple
	{
		function set dataProvider(dp:DataProvider):void;
		function get dataProvider():DataProvider;
		function set renderer(value:Class):void;
		function get renderer():Class;
		function set rowWidth(value:Number):void;
		function get rowWidth():Number;
		function set rowHeight(value:Number):void;
		function get rowHeight():Number;
		function set rowCount(value:uint):void;
		function get rowCount():uint;
		function set columnCount(value:uint):void;
		function get columnCount():uint;
		function set scrollY(value:Number):void;
		function get scrollY():Number;
	}
}