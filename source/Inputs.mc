using Toybox.WatchUi as Ui;

class Inputs extends Ui.InputDelegate
{
	var keyCB;
	var modelKeyCB;
	
	function initialize(handler, modelHandler)
	{
		keyCB = handler;
		modelKeyCB = modelHandler;
	}
	
    function onKey(evt)
    {
    	Sys.println(evt.getKey());
    	if(evt == Ui.KEY_ESC)
        {	
        	return keyCB.invoke(evt.getKey());
        }
        else
        {
        	return modelKeyCB.invoke(evt.getKey());
        }      	
    }
}