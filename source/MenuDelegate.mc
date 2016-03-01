using Toybox.WatchUi as Ui;

class MenuDelegate extends Ui.MenuInputDelegate
{
	var addDestinations;
	var getDestinations;
	
	function initialize(addDest, getDest)
	{
		addDestinations = addDest;
		getDestinations = getDest;
		System.println("initialize menuDelegate");
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