ADD JAR /usr/lib/hive/lib/hive-serdes-1.0-SNAPSHOT.jar;
Drop table if exists Yelp_Checkin;
CREATE EXTERNAL TABLE Yelp_Checkin(
    type STRING,
    business_id STRING,
    checkin_info MAP<STRING, INT>
)
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION
'hdfs://quickstart.cloudera:8020/cloudera/project/yelp/';
load data inpath './cloudera/project/yelp/checking.json' OVERWRITE INTO TABLE Yelp_Checkin;
