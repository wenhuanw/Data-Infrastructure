ADD JAR /usr/lib/hive/lib/hive-serdes-1.0-SNAPSHOT.jar;

CREATE EXTERNAL TABLE Yelp_Checkin(
    type STRING,
    business_id STRING,
    checkin_info MAP<STRING, INT>
)
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION
'/home/cloudera/YelpData/data/checkin';

create table Yelp_Checkin_tmp as select * from Yelp_Checkin;
