package mapreduce;

import parser.*;
import property.Property;

import java.io.IOException;
import java.io.StringReader;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;

import com.google.gson.Gson;
import com.google.gson.stream.JsonReader;

 
public class demo {
    
	public static class JsonMapper extends Mapper<Object, Text, Text, Text> {

		public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
			try {

	            JSONObject jsn = new JSONObject(value.toString());
	            
	            Gson gson = new Gson();
	            JsonReader reader = new JsonReader(new StringReader(value.toString()));
	            reader.setLenient(true);
	            Property property  = gson.fromJson(reader,Property.class); 
	            
	            //Property property  = gson.fromJson(value.toString(),Property.class); 
	            
//	            Collection<Property> readValues = new ObjectMapper().readValue(jsn.toString(), new TypeReference<Collection<Property>>() { });
//	            for(Property p : readValues){
//	            	System.out.println(p.user_id + "  "+ p.time_stamp + " " + p.getLocation().getX() + "  " + p.getLocation().getY());
//	            }
	            
			    context.write(new Text(property.user_id), new Text(property.time_stamp +" x is " + property.getLocation().getX()+ " y is " + property.getLocation().getY()));

			} catch (JSONException e) {
	            // TODO Auto-generated catch block
	            e.printStackTrace();

        }
    }
}
	
    public static void main(String[] args) throws Exception {
    	 runJob(args[0], args[1]);
    }
 

    
    public static void runJob(String input, String output) throws Exception {
    	
        Configuration conf = new Configuration();
        Job job = new Job(conf);
        job.setJarByClass(demo.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);
        job.setMapperClass(JsonMapper.class);
        //job.setInputFormatClass(KeyValueTextInputFormat.class);
        job.setNumReduceTasks(0);
        job.setOutputFormatClass(TextOutputFormat.class);

        FileInputFormat.setInputPaths(job, new Path(input));
        Path outPath = new Path(output);
        FileOutputFormat.setOutputPath(job, outPath);
        outPath.getFileSystem(conf).delete(outPath, true);

        job.waitForCompletion(true);
    }
}
