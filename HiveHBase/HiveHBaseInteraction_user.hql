1. File preparation
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/
[guan01@master1 ~]$ hadoop fs -mkdir -p /user/guan01/project/yelp/userExternal
[guan01@master1 ~]$ hadoop fs -put yelp_training_set_user.json /user/guan01/project/yelp/userExternal
[guan01@master1 ~]$ hadoop fs -ls /user/guan01/project/yelp/userExternal
[guan01@master1 ~]$ hadoop fs -put hive-serdes-1.0-SNAPSHOT.jar /user/guan01/project/yelp/



2. beeline
!connect jdbc:hive2://192.168.1.33:10000/default

ADD JAR hdfs:/user/guan01/project/yelp/hive-serdes-1.0-SNAPSHOT.jar;

USE guan_db;
DROP TABLE HiveToHBase_Yelp_User;
DROP TABLE Yelp_User;



3. Create HBase table from Hive 

CREATE TABLE HiveToHBase_Yelp_User(
    votes STRUCT<
                 useful:INT,  
                 funny:INT, 
                 cool:INT 
                >,
    user_id STRING,
    name STRING,
    average_stars DOUBLE,
    review_count INT,
    type STRING
    )
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = 'usercf:votes, :key, usercf:name, usercf:average_stars, usercf:review_count, usercf:type')
TBLPROPERTIES ('hbase.table.name' = 'Yelp_User_FromHive_Guan');



4. Create Yelp_Checkin in hive

CREATE EXTERNAL TABLE Yelp_User(
    votes STRUCT<
                 useful:INT,  
                 funny:INT, 
                 cool:INT 
                >,
    user_id STRING,
    name STRING,
    average_stars DOUBLE,
    review_count INT,
    type STRING
    )
COMMENT 'DATA ABOUT user on yelp'
ROW FORMAT SERDE 'com.cloudera.hive.serde.JSONSerDe'
LOCATION '/user/guan01/project/yelp/userExternal';



5. Interacting with data (FROM source_hive_table INSERT INTO TABLE my_hbase_table)

FROM Yelp_User INSERT INTO TABLE HiveToHBase_Yelp_User SELECT *;



Note:
If you try to load the data directly into table HiveToHBase_Yelp_Checkin you will get an error.
hive> LOAD DATA INPATH '/user/guan01/project/yelp/userExternal' OVERWRITE INTO TABLE HiveToHBase_Yelp_User;
FAILED: SemanticException [Error 10101]: A non-native table cannot be used as target for LOAD.


