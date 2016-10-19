package com.datalaus.de.spouts;

import java.util.Map;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.Properties;
import java.io.IOException;

import backtype.storm.Config;
import backtype.storm.spout.SpoutOutputCollector;
import backtype.storm.task.TopologyContext;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseRichSpout;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Values;
import backtype.storm.utils.Utils;
import twitter4j.conf.ConfigurationBuilder;
import twitter4j.FilterQuery;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.StallWarning;
import twitter4j.*;

import com.datalaus.de.utils.Constants;

public class TwitterSpout extends BaseRichSpout {
	
	private static final long serialVersionUID = 1L;

	SpoutOutputCollector coll;
	LinkedBlockingQueue<Status> statusqueue = new LinkedBlockingQueue<Status>();
	TwitterStream twitterStream;
	
	public void open(@SuppressWarnings("rawtypes") Map conf, TopologyContext context,SpoutOutputCollector collector) {
		// TODO Auto-generated method stub
		coll=collector;
		
		//Twitter account authentication from properties file
		final Properties properties = new Properties();
		try {
			properties.load(TwitterSpout.class.getClassLoader()
					                .getResourceAsStream(Constants.CONFIG_PROPERTIES_FILE));
		} catch (final IOException exception) {
			//LOGGER.error(exception.toString());
			System.exit(1);
		}

		
		//Configuring Twitter OAuth
		final ConfigurationBuilder configurationBuilder = new ConfigurationBuilder();
		configurationBuilder.setIncludeEntitiesEnabled(true);

		configurationBuilder.setOAuthAccessToken(properties.getProperty(Constants.OAUTH_ACCESS_TOKEN));
		configurationBuilder.setOAuthAccessTokenSecret(properties.getProperty(Constants.OAUTH_ACCESS_TOKEN_SECRET));
		configurationBuilder.setOAuthConsumerKey(properties.getProperty(Constants.OAUTH_CONSUMER_KEY));
		configurationBuilder.setOAuthConsumerSecret(properties.getProperty(Constants.OAUTH_CONSUMER_SECRET));
		//Twitter Stream Declaration
		twitterStream = new TwitterStreamFactory(configurationBuilder.build()).getInstance();
		
		StatusListener listener = new StatusListener(){

			public void onStatus(Status arg0) {
				statusqueue.offer(arg0);
			}
			//Irrelevant Functions
			public void onException(Exception arg0) {}
			
			public void onDeletionNotice(StatusDeletionNotice arg0) {}
		
			public void onScrubGeo(long arg0, long arg1) {}
			
			public void onStallWarning(StallWarning arg0) {}
		
			public void onTrackLimitationNotice(int arg0) {}
			
		};
		twitterStream.addListener(listener);

		FilterQuery tweetFilterQuery = new FilterQuery(); 
	    tweetFilterQuery.follow(new long[] { 739682825863995393L });

		twitterStream.filter(tweetFilterQuery);

	}

	
	public void nextTuple() {
		// TODO Auto-generated method stub
		Status tempst = statusqueue.poll();
		if(tempst==null)
			Utils.sleep(50);
		else
			System.out.println(tempst);
			coll.emit(new Values(tempst));
	}


	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		// TODO Auto-generated method stub
		declarer.declare(new Fields("tweet"));
	}

}

