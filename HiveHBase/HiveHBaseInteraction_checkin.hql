1. File preparation
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/checkinExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_checkin.json /user/guan01/project/yelp/checkinExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/checkinExternal
[guan01@master1 ~]$ hadoop fs -put hive-serdes-1.0-SNAPSHOT.jar /user/guan01/project/yelp/



2. beeline
!connect jdbc:hive2://192.168.1.33:10000/default

ADD JAR hdfs:/user/guan01/project/yelp/hive-serdes-1.0-SNAPSHOT.jar;

USE guan_db;
DROP TABLE HiveToHBase_Yelp_Checkin;
DROP TABLE Yelp_Checkin;



3. Create HBase table from Hive 

CREATE TABLE HiveToHBase_Yelp_Checkin(
    checkin_info MAP<STRING, INT>,
    type STRING,
    business_id STRING
    )
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = 'checkincf:checkin_info, checkincf:type, :key')
TBLPROPERTIES ('hbase.table.name' = 'Yelp_Checkin_FromHive_Guan');



4. Create Yelp_Checkin in hive

CREATE EXTERNAL TABLE Yelp_Checkin(
    checkin_info MAP<STRING, INT>,
    type STRING,
    business_id STRING
    )
COMMENT 'DATA ABOUT checkin on yelp'
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/guan01/project/yelp/checkinExternal';



5. Interacting with data (FROM source_hive_table INSERT INTO TABLE my_hbase_table)

FROM Yelp_Checkin INSERT INTO TABLE HiveToHBase_Yelp_Checkin SELECT *;



Note:
If you try to load the data directly into table HiveToHBase_Yelp_Checkin you will get an error.
hive> LOAD DATA INPATH '/user/guan01/project/yelp/checkinExternal' OVERWRITE INTO TABLE HiveToHBase_Yelp_Checkin;
FAILED: SemanticException [Error 10101]: A non-native table cannot be used as target for LOAD.


