using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Config;

class busmonkeyApp extends App.AppBase {

	hidden var view;
	hidden var model;
	hidden var inputs;
	
    //! onStart() is called on application start up
    function onStart() {
    
    	view = new BusMonkeyView();    	
        model = new BusMonkeyModel(view.method(:onStuff));
        inputs = new Inputs(model.method(:onKey));
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [view, inputs];
    }

}

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