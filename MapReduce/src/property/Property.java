package property;


import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.codehaus.jackson.annotate.JsonIgnoreProperties;
import org.codehaus.jackson.annotate.JsonProperty;
@JsonIgnoreProperties(ignoreUnknown = true)


public class Property {
	
		public static class Location {
		private String x, y;
		 
		public String getX() { return x; }
		public String getY() { return y; }
		 
		public void setFirst(String s) { x = s; }
		public void setLast(String s) { y = s; }
		}
		
		@JsonProperty("location")
		private Location location;
		@JsonProperty("time_stamp")
		public String time_stamp;
		@JsonProperty("user_id")
		public String user_id;
		

		
		public Location getLocation() { return location; }
		public String getStamp() { return time_stamp; }
		public String getId() { return user_id; }
		 
		public void setLocation(Location l) { location = l; }
		public void setStamp(String s) { time_stamp = s; }
		public void setUserId(String id) { user_id = id; }	
}


