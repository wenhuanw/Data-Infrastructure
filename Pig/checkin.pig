[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/checkinExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_checkin.json /user/guan01/project/yelp/checkinExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/checkinExternal
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/pigOutput


REGISTER '/home/guan01/piggybank.jar'; 
REGISTER '/home/guan01/elephant-bird-hadoop-compat-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-core-4.14-RC2.jar';
REGISTER '/home/guan01/elephant-bird-pig-4.14-RC2.jar';
REGISTER '/home/guan01/json-simple-1.1.1.jar';

json_checkin_row_jsonLoader = LOAD '/user/guan01/project/yelp/checkinExternal/yelp_training_set_checkin.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') AS (json:map []);


json_checkin_row = FOREACH json_checkin_row_jsonLoader GENERATE (map[])json#'checkin_info' As checkin_info, (chararray)json#'type' As type, (chararray)json#'business_id' As business_id;

-- check data 
DUMP json_checkin_row;

STORE json_checkin_row INTO 'hdfs:///user/guan01/project/yelp/pigOutput/json_checkin_table' USING PigStorage('\u0001');

-- find the business for those who have checkins of more than 10 on Wednesday betwwen 11AM-12PM
checkinWed11To12MoreThan10 = FILTER json_checkin_row BY checkin_info#'11-3' > 10;
DUMP checkinWed11To12MoreThan10;
