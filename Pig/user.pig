[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/userExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_user.json /user/guan01/project/yelp/userExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/userExternal
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/pigOutput


REGISTER '/home/guan01/piggybank.jar'; 
REGISTER '/home/guan01/elephant-bird-hadoop-compat-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-core-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-pig-4.14-RC2.jar';
REGISTER '/home/guan01/json-simple-1.1.1.jar';

json_user_row_jsonLoader = LOAD '/user/guan01/project/yelp/userExternal/yelp_training_set_user.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') AS (json:map []);


json_user_row = FOREACH json_user_row_jsonLoader GENERATE (map[])json#'votes' As votes, (chararray)json#'user_id' As user_id, (chararray)json#'name' As name, (double)json#'average_stars' As average_stars, (int)json#'review_count' As review_count, (chararray)json#'type' As type;

-- check data 
DUMP json_user_row;

STORE json_user_row INTO 'hdfs:///user/guan01/project/yelp/pigOutput/json_user_table' USING PigStorage('\u0001');

-- get business with rating below 3.0
SPLIT json_user_row INTO group_user_1 IF average_stars < 3.0, group_user_2 IF average_stars > 4.8, group_user_3 OTHERWISE;
DUMP group_user_1;
