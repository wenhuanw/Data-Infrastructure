[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_business.json /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/pigOutput


REGISTER '/home/guan01/piggybank.jar'; 
REGISTER '/home/guan01/elephant-bird-hadoop-compat-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-core-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-pig-4.14-RC2.jar';
REGISTER '/home/guan01/json-simple-1.1.1.jar';

json_business_row_jsonLoader = LOAD '/user/guan01/project/yelp/businessExternal/yelp_training_set_business.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') AS (json:map []);

json_business_row = FOREACH json_business_row_jsonLoader GENERATE (chararray)json#'business_id' As business_id, (chararray)REPLACE(json#'full_address', '\\n', ', ') As full_address, (boolean)json#'open' As open, json#'categories' As categories, (chararray)json#'city' As city, (int)json#'review_count' As review_count, (chararray)json#'name' As name, (double)json#'longitude' As longitude, (chararray)json#'state' As state, (double)json#'stars' As stars, (double)json#'latitude' As latitude;

STORE json_business_row INTO 'hdfs:///user/guan01/project/yelp/pigOutput/json_business_table' USING PigStorage('\u0001');

-- get business with rating below 3.0
SPLIT json_business_row INTO group_business_1 IF stars < 3.0, group_business_2 IF stars > 4.8, group_business_3 OTHERWISE;
DUMP group_business_1;
