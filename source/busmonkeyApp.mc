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
        setProperty("destinations", {});
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
    	var destinations = getProperty("destinations");
    	
    	for(var i=0; i<destinations.size(); i++)
    	{
    		menu.addItem(destinations.get(i), "d" + i);
    	}	
    	
    	Ui.pushView(menu, new MenuDelegate(), Ui.PRESS_TYPE_UP);
    }
}

class Picker extends Ui.TextPickerDelegate
{
	function onTextEntered(text, changed)
	{
		System.println(text);
		System.println(changed);
		
		var destinations = getProperty("destinations");
		destinations.put(new [12]);
	}
}

class MenuDelegate extends Ui.MenuInputDelegate
{
	function onMenuItem(item)
	{
		if (item == :item_add_new)
		{
			System.println("add new");		
			
			Ui.pushView(new Ui.TextPicker(), new Picker(), Ui.PRESS_TYPE_UP);
			
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