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
        inputs = new Inputs(method(:onKey));
        
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
        return [view, inputs];
    }
    
    function onKey(key)
    {
        if(key == Ui.KEY_ESC)
        {
        	openMenu();
        	return true;
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

class Picker extends Ui.TextPickerDelegate
{
	var addDestination;
	var getDestinations;
	
	function initialize(addDest, getDest)
	{
		addDestination = addDest;
		getDestinations = getDest;
		System.println("hello2");
	}
	
	function onTextEntered(text, changed)
	{
		System.println(text);
		System.println(changed);
		addDestination.invoke(text);
		Ui.popView(Ui.PRESS_TYPE_UP);
	}
}

class MenuDelegate extends Ui.MenuInputDelegate
{

	var addDestinations;
	var getDestinations;
	
	function initialize(addDest, getDest)
	{
		addDestinations = addDest;
		getDestinations = getDest;
		System.println("hello");
	}
	
	function onMenuItem(item)
	{
		if (item == :item_add_new)
		{
			System.println("add new");				
			Ui.pushView(new Ui.TextPicker(), new Picker(addDestinations, getDestinations), Ui.PRESS_TYPE_UP);
		}
		else if (item == :item_delete)
		{
			System.println("delete");
		}
		else
		{
			System.println(item);
		}
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