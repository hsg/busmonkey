using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Position;
using Toybox.Communications as Comm;
using Toybox.Math as Math;
using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;

class Route
{
	var error;
	var destinationName;
	var stopName;
	var stopShortCode;
	var distanceToStop;
	var walkTimeToStop;
	var busLeavesIn;
	var busCode;
	var busLine;
}

class BusMonkeyModel
{
	hidden var viewCB;
	
	hidden var latLon;
	hidden var sourceCoords;
	
    function initialize(handler)
    {
    	Sys.println("Waiting for GPS");
    	viewCB = handler;
		viewCB.invoke("Waiting for GPS");
		Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
    }
    
    function parseNumber(string)
 	{
 		if(string.substring(0, 1).equals("0"))
 		{
 			return string.substring(1, 2).toNumber();
 		}
 		else
 		{
 			return string.substring(0, 2).toNumber();
 		}
 	}
 	
 	function chopAtPoint(string)
 	{
 		var i = string.find(".");
 		if( i == null)
 		{
 			return string;
 		}
 		else
 		{
 			return string.substring(0, i);
 		}	
 	}
 	
 	var attempt = 0;
 	var url;
 	var callback;
 	
 	function handleResponse(responseCode, data)
 	{
 		if(responseCode == 200 && data != null)
 		{
 			attempt = 0;
 			onReceiveRoute(responseCode, data);
 		}
 		else if(attempt < 5)
 		{
 			var s = Lang.format("$1$ received\nCode $2$\n$3$\nRetrying..", [data, responseCode, message]);
 			viewCB.invoke(s);
 			attempt++;
 			makeRequest(url, callback);
 		}
 		else
 		{
 			var s = Lang.format("$1$ received\nCode $2$\n$3$\nFailed.", [data, responseCode, message]);
 			viewCB.invoke(s);
 			attempt = 0;
 		}
 	}
 	
 	function makeRequest(u, c)
 	{
 		url = u;
 		callback = c;
		Comm.makeJsonRequest(url, null, null, method(:handleResponse));
 	}
    
    function onReceiveRoute(responseCode, data)
    {	
		var depTime = data["depTime"];
			
		var busLeavesAt = Calendar.moment({
			:year => depTime.substring(0, 4).toNumber(),
			:month => parseNumber(depTime.substring(4, 6)),
			:day => parseNumber(depTime.substring(6, 8)),
			:hour => parseNumber(depTime.substring(8, 10)),
			:minute => parseNumber(depTime.substring(10, 12))});

		Sys.println(Lang.format("TimeZoneOffset $1$", [Sys.getClockTime().timeZoneOffset.toString()]));
		Sys.println(Lang.format("LeavesAt $1$", [depTime]));
		Sys.println(Lang.format("LeavesAtParsed $1$", [busLeavesAt.value().toString()]));
		Sys.println(Lang.format("Now $1$", [Time.now().value().toString()]));
		
		var now = Time.now().add(new Time.Duration(Sys.getClockTime().timeZoneOffset));

		var routeData = new Route();

		routeData.busLeavesIn = busLeavesAt.subtract(now).value();
		routeData.stopName = data["stopName"];
		routeData.stopShortCode = data["stopShortCode"];
		routeData.distanceToStop = data["distanceToStop"];
		routeData.walkTimeToStop = chopAtPoint(data["walkTimeToStop"].toString()).toNumber();
		routeData.busCode = data["busCode"];
		routeData.busLine = data["busLine"];
		routeData.destinationName = data["destinationName"];
		
		viewCB.invoke(routeData);
    }
    
    function reverseGeocode(lat, lon)
    {
     	Sys.println("reverseGeocode");
     	viewCB.invoke(lat + "," + lon);
     	var destination = "Kamppi";
		var url = Lang.format(Config.url, [lat, lon, destination]);
		Sys.println(url);
		makeRequest(url, method(:onReceiveRoute));
    }
    
    function onPosition(data)
    {

    	Sys.println("onPosition");
        latLon = data.position.toDegrees();

		//Sys.println(data.position.toGeoString());
		Sys.println(data.position.toRadians()[0].toString());
        Sys.println(latLon[0].toString());
        Sys.println(latLon[1].toString());
		
		reverseGeocode(latLon[0].toString(), latLon[1].toString());			
     }
     
    function onKey(key)
    {
    	
    	if(key == Ui.KEY_ENTER)
    	{
    		var routeData = new Route();
        	routeData.stopName = "Maarinniitty";
			routeData.stopShortCode = "E2072";
			routeData.distanceToStop = "253";
			routeData.walkTimeToStop = 180;
			routeData.busLeavesIn = 18 * 60;
			routeData.busCode = "asdf";
			routeData.busLine = "103T";
			routeData.destinationName = "Kamppi";
			viewCB.invoke(routeData);
			return true;
        }      
        if(key == Ui.KEY_ESC)
        {
        	openMenu();
        	return true;
        } 
        return false;
    }
    
    function openMenu() 
    {
    	Ui.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), Ui.PRESS_TYPE_UP);
    }
}


class BusMonkeyView extends Ui.View {

	var displayData;

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();
		//sys.println(displayData.toString());
		if(displayData instanceof Route)
		{
			// Line, from
			var text = Lang.format("Bus $1$ to\n$2$ from\n$3$ ($4$)", [displayData.busLine, displayData.destinationName, displayData.stopName, displayData.stopShortCode]);			
			dc.drawText(dc.getWidth()/2, 50, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			
			// x m, y min walk
			text = Lang.format("\n$1$m ($2$min)\nwalk", [displayData.distanceToStop, displayData.walkTimeToStop/60]);
			dc.drawText(65, 150, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			//dc.drawText(40, 140, Graphics.FONT_TINY, "walk", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			
			// in .. minutes
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_MEDIUM, "    in       min", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

			// minutes
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_LARGE, (displayData.busLeavesIn / 60).toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			
			// compass
			dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(130, 170, Graphics.FONT_SMALL, "NE", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawCircle(165, 160, 20);
			dc.drawLine(165, 160, 187, 148);
			
		}
		else
		{
			dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_TINY, displayData, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		}
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }
    
    function onStuff(stuff)
    {
        System.println("onStuff");
        displayData = stuff;
        Ui.requestUpdate();
        
    }
}

class MenuDelegate extends Ui.MenuInputDelegate
{
	function onMenuItem(item)
	{
		if (item == :item_1)
		{
			System.println("menu item 1");		
		}
		else if (item == :item_2)
		{
			System.println("menu item 2");
		}
	}
}

