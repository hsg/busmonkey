using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class Inputs extends Ui.InputDelegate
{
	var keyCB;
	
	function initialize(handler)
	{
		keyCB = handler;
	}
	
    function onKey(evt)
    {
    	Sys.println(evt.getKey());
    	return keyCB.invoke(evt.getKey());    	
    }
}