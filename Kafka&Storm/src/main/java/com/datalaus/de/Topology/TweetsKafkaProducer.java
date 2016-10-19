package com.datalaus.de.Topology;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import com.datalaus.de.spouts.TwitterSpout;
import com.datalaus.de.utils.Constants;

import twitter4j.FilterQuery;
import twitter4j.StallWarning;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.URLEntity;
import twitter4j.conf.ConfigurationBuilder;

public class TweetsKafkaProducer extends Thread {
	TwitterStream twitterStream;
	StatusListener listener;
	KafkaProducer producer;
	long uid;
	
	public TweetsKafkaProducer(long Userid, String kafkaserver){
		//Twitter account authentication from properties file
		uid = Userid;
		final Properties properties = new Properties();
		try {
			properties.load(TwitterSpout.class.getClassLoader()
					                .getResourceAsStream(Constants.CONFIG_PROPERTIES_FILE));
		} catch (final IOException exception) {
			//LOGGER.error(exception.toString());
			System.exit(1);
		}
		
		//build kafka producer
		Properties props = new Properties();
		props.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaserver);
		props.setProperty(ProducerConfig.METADATA_FETCH_TIMEOUT_CONFIG, Integer.toString(5 * 1000));
		props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
		props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
		producer = new KafkaProducer(props);
		
		//Configuring Twitter OAuth
		final ConfigurationBuilder configurationBuilder = new ConfigurationBuilder();
		configurationBuilder.setIncludeEntitiesEnabled(true);

		configurationBuilder.setOAuthAccessToken(properties.getProperty(Constants.OAUTH_ACCESS_TOKEN));
		configurationBuilder.setOAuthAccessTokenSecret(properties.getProperty(Constants.OAUTH_ACCESS_TOKEN_SECRET));
		configurationBuilder.setOAuthConsumerKey(properties.getProperty(Constants.OAUTH_CONSUMER_KEY));
		configurationBuilder.setOAuthConsumerSecret(properties.getProperty(Constants.OAUTH_CONSUMER_SECRET));
		//Twitter Stream Declaration
		twitterStream = new TwitterStreamFactory(configurationBuilder.build()).getInstance();
		
		listener = new StatusListener(){

			public void onStatus(Status arg0) {
				ProducerRecord<String, String> data = new ProducerRecord("topic1", arg0.getText());
				producer.send(data);
			}
			//Irrelevant Functions
			public void onException(Exception arg0) {}
			
			public void onDeletionNotice(StatusDeletionNotice arg0) {}
		
			public void onScrubGeo(long arg0, long arg1) {}
			
			public void onStallWarning(StallWarning arg0) {}
		
			public void onTrackLimitationNotice(int arg0) {}
			
		};

	}
	
	public void run(){
		twitterStream.addListener(listener);

		FilterQuery tweetFilterQuery = new FilterQuery(); 

	    tweetFilterQuery.follow(new long[] {uid});

		twitterStream.filter(tweetFilterQuery);		
	}
}
