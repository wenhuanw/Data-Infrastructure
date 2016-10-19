## twitter Streaming
import time
from pyspark import SparkContext
from pyspark.streaming import StreamingContext
import twitter
import dateutil.parser
import json
from pyspark.streaming.kafka import KafkaUtils

# Connecting Streaming Twitter with Streaming Spark via Queue
class Tweet(dict):
    def __init__(self, tweet_in):
        super(Tweet, self).__init__(self)
        if tweet_in and 'delete' not in tweet_in:
            self['timestamp'] = dateutil.parser.parse(tweet_in[u'created_at']).replace(tzinfo=None).isoformat()
            self['text'] = tweet_in['text'].encode('utf-8')
            #self['text'] = tweet_in['text']
            self['hashtags'] = [x['text'].encode('utf-8') for x in tweet_in['entities']['hashtags']]
            #self['hashtags'] = [x['text'] for x in tweet_in['entities']['hashtags']]
            self['geo'] = tweet_in['geo']['coordinates'] if tweet_in['geo'] else None
            self['id'] = tweet_in['id']
            self['screen_name'] = tweet_in['user']['screen_name'].encode('utf-8')
            #self['screen_name'] = tweet_in['user']['screen_name']
            self['user_id'] = tweet_in['user']['id']

def connect_twitter():
    twitter_stream = twitter.TwitterStream(auth=twitter.OAuth(
        token = "739682825863995393-ecE6XipKWPtuTwC0m7vd5JRr2hNwBYX",
        token_secret = "jGUKOHW6AdbICJsLcCbO3YFb86dBUHAp5P3IbueJ1O51a",
        consumer_key = "zrG3CPkCa6x0NQmGKci7GVLBL",
        consumer_secret = "RIuXUc8qwh8EywXVSUqNj48nkZYLtUsQGxc7pK6XxJQvCCDOeN"))

    return twitter_stream

def get_next_tweet(twitter_stream):
    stream = twitter_stream.statuses.sample(block=True)
    tweet_in = None
    while not tweet_in or 'delete' in tweet_in:
        tweet_in = stream.next()
        tweet_parsed = Tweet(tweet_in)
    return json.dumps(tweet_parsed)

def stream(ssc):

    zkQuorum = "localhost:2181"
    topic = "topic1"
    tweets = KafkaUtils.createStream(ssc, zkQuorum, "spark-streaming-consumer", {topic: 1})
    kstream = KafkaUtils.createDirectStream(ssc, topics = ['topic1'], kafkaParams = {"metadata.broker.list":"localhost:9092"})

    tweets = tweets.map(lambda x: x[1].encode("ascii","ignore"))
    return tweets

def process_rdd_queue(twitter_stream):
        # Create the queue through which RDDs can be pushed to
        # a QueueInputDStream
    rddQueue = [] 
    for i in range(3):
        rddQueue += [ssc.sparkContext.parallelize([get_next_tweet(twitter_stream)], 5)]
    lines = ssc.queueStream(rddQueue)
    lines.pprint()

if __name__ == "__main__":
    sc = SparkContext(appName="PythonStreamingQueueStream")
    ssc = StreamingContext(sc, 10)
    # Instantiate the twitter_stream
    #twitter_stream = connect_twitter()
    # Get RDD queue of the streams json or parsed
    #process_rdd_queue(twitter_stream)
    zkQuorum = "localhost:2181"
    topic = "topic1"
    tweets = KafkaUtils.createStream(ssc, zkQuorum, "PythonStreamingQueueStream", {topic: 1})
    #tweets = stream(ssc)
    #process_rdd_queue(twitter_stream)
    tweets.pprint()	
    ssc.start()
    time.sleep(100)
    ssc.stop(stopSparkContext=True, stopGraceFully=True)
