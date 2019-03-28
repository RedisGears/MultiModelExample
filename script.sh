#!/bin/bash -x

redis-cli MODULE LOAD /home/guy/redisconf/RedisGears/redisgears.so

read

redis-cli HSET marsman:100 Name Douglas Last Quaid
redis-cli HSET marsman:101 Name Lori Last Quaid       # Quaid's seemingly loving wife

read

######## RediSearch ################################################################################################# 

redis-cli MODULE LOAD /home/guy/redisconf/RediSearch/src/redisearch.so SAFEMODE

read

redis-cli FT.CREATE marsmen SCHEMA Name Text Last Text

read

# Index existing marsmen
redis-cli RG.PYEXECUTE \
"GearsBuilder()\
.foreach(lambda x: execute('FT.ADDHASH', 'marsmen', x['key'], '1.0', 'REPLACE'))\
.count()\
.run('marsman:*')"

# Register for new/update marsmen
redis-cli RG.PYEXECUTE \
"GearsBuilder()\
.foreach(lambda x: execute('FT.ADDHASH', 'marsmen', x['key'], '1.0', 'REPLACE'))\
.register('marsman:*')"

read

redis-cli FT.SEARCH marsmen Qu*

read

redis-cli HSET marsman:102 Name Vilos Last Cohaagen # Governor of the Mars 
redis-cli HSET marsman:103 Name Bob Last McClane    # Rekall manager and sales agent 

read

redis-cli FT.SEARCH marsmen mcc*

read

######## RedisGraph ################################################################################################# 

redis-cli MODULE LOAD /home/guy/redisconf/RedisGraph/src/redisgraph.so

read

redis-cli HSET marsman:101 Relation marsman:100

read

# Create nodes for all marsmen
redis-cli RG.PYEXECUTE \
"GearsBuilder()\
.foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MERGE ( :marsman {ID:\"%s\"})' % x['key']))\
.foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MATCH (n:marsman {ID:\"%s\"}) SET n.Name=\"%s\", n.Last=\"%s\"' % (x['key'], x['value']['Name'], x['value']['Last'])))\
.count()\
.run('marsman:*')"

# Create relations
redis-cli RG.PYEXECUTE \
"GearsBuilder()\
.filter(lambda x: 'Relation' in x['value'].keys())\
.foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MATCH (a:marsman), (b:marsman) where a.ID=\"%s\" AND b.ID=\"%s\" CREATE (a)-[:Relation]->(b)' % (x['key'], x['value']['Relation'])))\
.run('marsman:*')"

# Register for new nodes/relations update
redis-cli RG.PYEXECUTE \
"GearsBuilder()\
.foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MERGE ( :marsman {ID:\"%s\"})' % x['key']))\
.foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MATCH (n:marsman {ID:\"%s\"}) SET n.Name=\"%s\", n.Last=\"%s\"' % (x['key'], x['value']['Name'], x['value']['Last'])))\
.foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MATCH (a:marsman)-[r:Relation]->() where a.ID=\"%s\" DELETE r' % (x['key'])))\
.filter(lambda x: 'Relation' in x['value'].keys())\
.foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MATCH (a:marsman), (b:marsman) where a.ID=\"%s\" AND b.ID=\"%s\" CREATE (a)-[:Relation]->(b)' % (x['key'], x['value']['Relation'])))\
.register('marsman:*')"

read

redis-cli GRAPH.QUERY marsmen "MATCH (n)-[:Relation]->(m) return n.Name, m.Name"

read

redis-cli HSET marsman:104 Name Robert Last Costanzo Relation marsman:100 # Quaid's workmate (Cohaagen's agent)

read

redis-cli GRAPH.QUERY marsmen "MATCH (n)-[:Relation]->(m) return n.Name, m.Name"


read

redis-cli HDEL marsman:104 Relation # Quaid killed! Robert

read

redis-cli GRAPH.QUERY marsmen "MATCH (n)-[:Relation]->(m) return n.Name, m.Name"
 
######## RedisTimeSeries ############################################################################################ 

redis-cli MODULE LOAD /home/guy/redisconf/RedisTimeSeries/src/redistimeseries.so

read

# Register for new hearbeat event
redis-cli RG.PYEXECUTE \
"GearsBuilder()\
.foreach(lambda x: execute('TS.ADD', 'heartbeat:'+ x['key'], '*', x['value']['HeartBeat']))\
.register('marsman:*')"

read

for rate in 60 65 70 80 95 120 150 200 250 300 350 350 350 350 350 350 350 200 150 100 90 80 
do
	redis-cli HSET marsman:100 HeartBeat $rate
	sleep 1
done

read

redis-cli TS.RANGE heartbeat:marsman:100 - +
