using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Config;

class busmonkeyApp extends App.AppBase {

	hidden var view;
	hidden var model;
	hidden var inputHandler;
	
    //! onStart() is called on application start up
    function onStart() {
    
    	view = new BusMonkeyView();    	
        model = new BusMonkeyModel(view.method(:redraw));
        inputHandler = new Inputs(method(:onKey));
        
        //if not destinations type of dictionary, create new.
		var dest = getProperty("destinations");
		if(!(dest instanceof Dictionary))
		{
			setProperty("destinations", {});
		}
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [view, inputHandler];
    }
    
    function onKey(key)
    {
        if(key == Ui.KEY_ESC)
        {
        	openMenu();
        	return true;
        } 
        else
        {
	        if(key == Ui.KEY_DOWN)
	    	{
        		model.showDemoScreen();
        		return true;
        	}
        }
        
        return false;
    }
    
    function openMenu() 
    {
    	var menu = new Rez.Menus.MainMenu();
    	var dest = getDestinations();
    	
    	for(var i=0; i<dest.size(); i++)
    	{
    		menu.addItem(dest[i], "d" + i);
    	}	
    	
    	Ui.pushView(menu, new MenuDelegate(method(:addDestination), method(:getDestinations)), Ui.PRESS_TYPE_UP);
    }
    
    function addDestination(d)
    {
    	var dest = getProperty("destinations");
		dest.put(d, d);
		setProperty("destinations", dest);
    }
    
    function getDestinations()
    {
    	return getProperty("destinations").keys();
    }
}