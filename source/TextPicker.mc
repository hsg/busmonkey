using Toybox.WatchUi as Ui;

class TextPicker extends Ui.TextPickerDelegate
{
	var addDestination;
	var getDestinations;
	
	function initialize(addDest, getDest)
	{
		addDestination = addDest;
		getDestinations = getDest;
		System.println("initialize picker");
	}
	
	function onTextEntered(text, changed)
	{
		System.println(text);
		System.println(changed);
		addDestination.invoke(text);
		Ui.popView(Ui.PRESS_TYPE_UP);
	}
}