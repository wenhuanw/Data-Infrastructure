Drop table business;
CREATE  EXTERNAL  TABLE business
(
value STRING 
)
LOCATION  '/home/cloudera/project/yelp';

LOAD DATA INPATH '/home/cloudera/project/yelp/business.json' OVERWRITE INTO TABLE business;

SELECT 
  GET_JSON_OBJECT(business.value,'$.stars'), 
  GET_JSON_OBJECT(business.value,'$.name'),
 GET_JSON_OBJECT(business.value,'$.city'),
GET_JSON_OBJECT(business.value,'$.review_count')
FROM business;
