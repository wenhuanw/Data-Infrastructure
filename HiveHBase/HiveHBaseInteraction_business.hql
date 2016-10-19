1. File preparation
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_business.json /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/businessExternal
[guan01@master1 ~]$ hadoop fs -put hive-serdes-1.0-SNAPSHOT.jar /user/guan01/project/yelp/



2. beeline
!connect jdbc:hive2://192.168.1.33:10000/default

ADD JAR hdfs:/user/guan01/project/yelp/hive-serdes-1.0-SNAPSHOT.jar;

USE guan_db;
DROP TABLE HiveToHBase_Yelp_Business;
DROP TABLE Yelp_Business;



3. Create HBase table from Hive 

CREATE TABLE HiveToHBase_Yelp_Business(
    business_id STRING,
    full_address STRING,
    open BOOLEAN,
    categories ARRAY<STRING>,
    city STRING,
    review_count INT,
    name STRING,
    neighborhoods ARRAY<STRING>,
    longitude DOUBLE,
    state STRING,
    stars DOUBLE,
    latitude DOUBLE,
    type STRING
    )
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key, businesscf:full_address, businesscf:open, businesscf:categories, businesscf:city, businesscf:review_count, businesscf:name, businesscf:neighborhoods, businesscf:longitude, businesscf:state, businesscf:stars, businesscf:latitude, businesscf:type')
TBLPROPERTIES ('hbase.table.name' = 'Yelp_Business_FromHive_Guan');



4. Create Yelp_Business in hive

CREATE EXTERNAL TABLE Yelp_Business(
    business_id STRING,
    full_address STRING,
    open BOOLEAN,
    categories ARRAY<STRING>,
    city STRING,
    review_count INT,
    name STRING,
    neighborhoods ARRAY<STRING>,
    longitude DOUBLE,
    state STRING,
    stars DOUBLE,
    latitude DOUBLE,
    type STRING
    )
COMMENT 'DATA ABOUT businesss on yelp'
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/guan01/project/yelp/businessExternal';



5. Interacting with data (FROM source_hive_table INSERT INTO TABLE my_hbase_table)

FROM Yelp_Business INSERT INTO TABLE HiveToHBase_Yelp_Business SELECT *;



Note:
If you try to load the data directly into table HiveToHBase_Yelp_Business you will get an error.
hive> LOAD DATA INPATH '/user/guan01/project/yelp/businessExternal' OVERWRITE INTO TABLE HiveToHBase_Yelp_Business;
FAILED: SemanticException [Error 10101]: A non-native table cannot be used as target for LOAD.


