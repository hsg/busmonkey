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
	var walkTimeToStop = 0;
	var busLeavesIn = 0;
	var busCode;
	var busLine;
	//var stopCoordX;
	//var stopCoordY;
	//var startCoordX;
	//var startCoordY;
	var directionToWalk;
	var currentDirection;
	var validUntil;
}

function calculateCompass(d)
{
	if(d == null)
	{
		return null;
	}
		
	var c;
    if(d < 22.5) {
        c = "N"; }
    else if(d < 67.5) {
        c = "NE"; }
    else if(d < 112.5) {
        c = "E"; }
    else if(d < 157.5) {
        c = "SE"; }
    else if(d < 202.5) {
        c = "S"; }
    else if(d < 247.5) {
        c = "SW"; }
    else if(d < 292.5) {
        c = "W"; }
    else if(d < 337.5) {
        c = "NW"; }
    else {
        c = "N"; }
        
    return c;
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
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		
		var center_x = dc.getWidth()/2;
		var center_y = dc.getHeight()/2;
		
		//sys.println(displayData.toString());
		if(displayData instanceof Route)
		{
			// compass
			
			var cx = center_x;
			var cy = center_y;
			var cr = center_x - 8;
			var currentCompass = calculateCompass(displayData.currentDirection);
			var walkCompass = calculateCompass(displayData.directionToWalk);

			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
			dc.drawCircle(cx, cy, cr);

			dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
			
			if(currentCompass != null)
			{
				dc.drawText(cx, cy - cr - 5, Graphics.FONT_XTINY, currentCompass, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
				dc.drawLine(cx, cy, cx, cy - cr - 1); //straight up
			}
			
			if(walkCompass != null)
			{
				var endX = cx + (cr+1) * Math.sin(displayData.directionToWalk);
				var endY = cy + (cr+1) * Math.cos(displayData.directionToWalk);			
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
				dc.drawLine(cx, cy, endX, endY); // heading to stop
				dc.drawCircle(endX, endY, 2);
				dc.drawText(endX, endY, Graphics.FONT_XTINY, walkCompass, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);			
			}
					
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		
			if(displayData.busLine != null)
			{
				// Line, from
				var text = Lang.format("Bus $1$ to\n$2$ from\n$3$ ($4$)", [displayData.busLine, displayData.destinationName, displayData.stopName, displayData.stopShortCode]);			
				dc.drawText(center_x, 70, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			}
			else
			{
				// Line, from
				var text = "Waiting for route";			
				dc.drawText(center_x, 70, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			}
			
			if(displayData.distanceToStop != null)
			{
				// x m, y min walk
				var text = Lang.format("\n$1$m ($2$min)\nwalk", [displayData.distanceToStop, displayData.walkTimeToStop/60]);
				dc.drawText(center_x, 170, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
				//dc.drawText(40, 140, Graphics.FONT_TINY, "walk", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
				
				// in .. minutes
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
				dc.drawText(center_x, 130, Graphics.FONT_MEDIUM, "    in       min", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
	
				// minutes
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
				dc.drawText(center_x, 130, Graphics.FONT_LARGE, (displayData.busLeavesIn / 60).toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			}		
		}
		else
		{
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
			dc.drawText(center_x, center_y, Graphics.FONT_TINY, displayData, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		}
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }
    
    function redraw(content)
    {
        System.println("redraw");
        displayData = content;
        Ui.requestUpdate();  
    }
}


