ADD JAR /usr/lib/hive/lib/hive-serdes-1.0-SNAPSHOT.jar;

CREATE EXTERNAL TABLE Yelp_Business(
    type STRING,
    business_id STRING,
    name STRING,
    neighborhoods ARRAY<STRING>,
    full_address STRING,
    city STRING,
    state STRING,
    latitude DOUBLE,
    longitude DOUBLE,
    stars DOUBLE,
    review_count INT,
    categories array<STRING>,
    open BOOLEAN
)
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION
'/home/cloudera/YelpData/data/business';

create table Yelp_Business_tmp as select * from Yelp_Business;
