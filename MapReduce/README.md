# GameAnalysisDemo

#way to compile

$ mvn clean
$ mvn package

$ hadoop fs -mkdir /user/cloudera/GameLogAnalysis/intput/1

$ hadoop fs -put demo.txt /user/cloudera/GameLogAnalysis/input/1

$ hadoop fs -mkdir /user/cloudera/GameLogAnalysis/output/1

$ hadoop jar target/src.mapreduce.demo-0.0.1-SNAPSHOT.jar mapreduce.demo /user/cloudera/GameLogAnalysis/input/1 /user/cloudera/GameLogAnalysis/output/1

$ hadoop fs -cat /user/cloudera/GameLogAnalysis/output/1/*

######### sanpple output
UID964	2015-07-01 19:19:13 x is 292 y is 156 

UID442	2015-07-01 19:19:13 x is 323 y is 135

UID314	2015-07-01 19:19:13 x is 316 y is 153

UID711	2015-07-01 19:19:13 x is 310 y is 131

UID397	2015-07-01 19:19:13 x is 347 y is 170

UID120	2015-07-01 19:19:13 x is 355 y is 122

UID591	2015-07-01 19:19:13 x is 213 y is 117

UID164	2015-07-01 19:19:13 x is 341 y is 125

UID187	2015-07-01 19:19:13 x is 382 y is 135

UID623	2015-07-01 19:19:13 x is 359 y is 137



