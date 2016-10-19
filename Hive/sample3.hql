CREATE EXTERNAL TABLE yelp_business_not_orc(
    business_id String,
    name String,
    categories String,
    review_count int, 
    stars String, 
    open String,
    full_address String,
    city String,
    state String,
    longitude String,
    latitude String
    )
COMMENT 'intermediate non orc table, DATA ABOUT businesss on yelp'
ROW FORMAT
DELIMITED FIELDS TERMINATED BY '\001'
LINES TERMINATED BY '\n';
LOAD DATA INPATH '/home/cloudera/project/yelp/business.json' OVERWRITE INTO TABLE yelp_business_not_orc;
