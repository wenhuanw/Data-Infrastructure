[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/reviewExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_review.json /user/guan01/project/yelp/reviewExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/reviewExternal
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/pigOutput


REGISTER '/home/guan01/piggybank.jar'; 
REGISTER '/home/guan01/elephant-bird-hadoop-compat-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-core-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-pig-4.14-RC2.jar';
REGISTER '/home/guan01/json-simple-1.1.1.jar';

json_review_row_jsonLoader = LOAD '/user/guan01/project/yelp/reviewExternal/yelp_training_set_review.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') AS (json:map []);


json_review_row = FOREACH json_review_row_jsonLoader GENERATE (map[])json#'votes' As votes, (chararray)json#'user_id' As user_id, (chararray)json#'review_id' As review_id, (double)json#'stars' As stars, (chararray)json#'date' As date, (chararray)json#'text' As text;

-- check data 
DUMP json_review_row;

STORE json_review_row INTO 'hdfs:///user/guan01/project/yelp/pigOutput/json_review_table' USING PigStorage('\u0001');

-- get review info after 2012-06-01
reviewAfter2012_06_01 = FILTER json_review_row BY date > '2012-06-01';
DUMP reviewAfter2012_06_01;