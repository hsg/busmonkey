using Toybox.System as Sys;
using Config;
using Tools;
using Toybox.Position;
using Toybox.Communications as Comm;
using Toybox.Math as Math;
using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;

class BusMonkeyModel
{
	hidden var viewRedrawCB;
	
	hidden var latLon;
	hidden var heading;	
	hidden var sourceCoords;	
	hidden var lastRouteData = new Route();
	
    function initialize(viewRedrawCallback)
    {
    	Sys.println("Waiting for GPS");
    	viewRedrawCB = viewRedrawCallback;
		viewRedrawCB.invoke(lastRouteData);
		Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }
    
    function stopProgram()
	{
		Position.enableLocationEvents(LOCATION_DISABLE, null);
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
 		else if(responseCode == -104)
 		{
 			viewRedrawCB.invoke("Bluetooth/nunavailable");
 			stopProgram();
 		}
 		else if(attempt < 5)
 		{
 			Sys.println(data);
 			Sys.println(responseCode);
 			var s = Lang.format("$1$ received\nCode $2$\n$3$\nRetrying..", [data, responseCode, ""]);
 			viewRedrawCB.invoke(s);
 			attempt++;
 			makeRequest(url, callback);
 		}
 		else
 		{
 			var s = Lang.format("$1$ received\nCode $2$\n$3$\nFailed.", [data, responseCode, ""]);
 			viewRedrawCB.invoke(s);
 			attempt = 0;
 			stopProgram();
 		}
 	}
 	
 	function makeRequest(u, c)
 	{
 		url = u;
 		callback = c;
		Comm.makeJsonRequest(url, null, null, method(:handleResponse));
 	}
    
    function parseReceivedData(data)
    {
    	var depTime = data["depTime"];
			
		var busLeavesAt = Calendar.moment({
			:year => depTime.substring(0, 4).toNumber(),
			:month => Tools.parseNumber(depTime.substring(4, 6)),
			:day => Tools.parseNumber(depTime.substring(6, 8)),
			:hour => Tools.parseNumber(depTime.substring(8, 10)),
			:minute => Tools.parseNumber(depTime.substring(10, 12))});

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
		routeData.walkTimeToStop = Tools.chopAtPoint(data["walkTimeToStop"].toString()).toNumber();
		routeData.busCode = data["busCode"];
		routeData.busLine = data["busLine"];
		routeData.destinationName = data["destinationName"];
		
		routeData.validUntil = busLeavesAt.value() - routeData.walkTimeToStop;
		
		var directionToStop = data["directionToStop"];
		var directionToWalk = directionToStop - heading;
        if(directionToWalk < 0)
        {
        	directionToWalk = 360 + directionToWalk;
        }
        routeData.directionToWalk = directionToWalk;
        Sys.println("stopDir: " + directionToStop);
        Sys.println("walkdir: " + directionToWalk);
        
        routeData.currentDirection = heading;
        
        return routeData;
    }
    
    function onReceiveRoute(responseCode, data)
    {	
    	lastRouteData = parseReceivedData(data);
		viewRedrawCB.invoke(lastRouteData);
    }
    
    function fetchRoute(lat, lon)
    {
     	Sys.println("fetchRoute");
     	viewRedrawCB.invoke(lat + "," + lon);
     	
     	var destination = "Kamppi"; //getProperty("destinations")[0];
     	var optimize = "fastest";
     	
		var url = Lang.format(Config.url, [lat, lon, destination, optimize]);
		Sys.println(url);
		makeRequest(url, method(:onReceiveRoute));
    }
    
    function needNewRoute()
    {
    	if(lastRouteData == null || lastRouteData.validUntil == null)
    	{
    		return true;
    	}
    	if(lastRouteData.validUntil < Time.now().value())
    	{
    		return true;
    	}
    	//if position changed enought, return true
    	
    	
    	return false;
    }
    
    function onPosition(data)
    {

    	Sys.println("onPosition");
        latLon = data.position.toDegrees();

		//Sys.println(data.position.toGeoString());
		//Sys.println(data.position.toRadians()[0].toString());
        Sys.println("lat: " + latLon[0].toString());
        Sys.println("lon: " + latLon[1].toString());
        
        //Sys.println(data.heading);
        heading = 90 - (180/Math.PI) * data.heading;
        Sys.println("heading: " + heading);
        
        if(needNewRoute())
        {
        	Sys.println("need new route..");
			fetchRoute(latLon[0].toString(), latLon[1].toString());
		}
		else
		{
			Sys.println("Using old route");
			viewRedrawCB.invoke(lastRouteData);
		}			
     }
     
    function showDemoScreen()
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
		routeData.directionToWalk = 100;
		routeData.currentDirection = 222;
		viewRedrawCB.invoke(routeData);
    }
}
