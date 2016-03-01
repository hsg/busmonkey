module Tools
{
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

}