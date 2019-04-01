#!/bin/bash -x

redis-cli MODULE LOAD `pwd`/redisgears.so

read

redis-cli HSET marsman:100 Name Douglas Last Quaid
redis-cli HSET marsman:101 Name Lori Last Quaid       # Quaid's seemingly loving wife
redis-cli HSET marsman:102 Name Melina Last Melina 

read -p "Back to slides..."

######## RediSearch ################################################################################################# 

redis-cli MODULE LOAD `pwd`/redisearch.so SAFEMODE

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

read -p "Back to slides..."

redis-cli HSET marsman:103 Name Vilos Last Cohaagen # Governor of the Mars 
redis-cli HSET marsman:104 Name Bob Last McClane    # Rekall manager and sales agent 
redis-cli HSET marsman:105 Name Harry Last Harry    # Douglas friend
read

redis-cli FT.SEARCH marsmen mcc*

read -p "Back to slides..."

######## RedisGraph ################################################################################################# 

redis-cli MODULE LOAD `pwd`/redisgraph.so

read

redis-cli HSET marsman:101 Relation marsman:100

read

# Create nodes for all marsmen
redis-cli RG.PYEXECUTE \
"GearsBuilder()\
.foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MERGE (n:marsman {ID:\"%s\", Name:\"%s\", Last:\"%s\"})' % (x['key'], x['value']['Name'], x['value']['Last'])))\
.count()\
.run('marsman:*')"

# Create relations
redis-cli RG.PYEXECUTE \
"GearsBuilder()\
.filter(lambda x: 'Relation' in x['value'].keys())\
.foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MATCH (a:marsman), (b:marsman) where a.ID=\"%s\" AND b.ID=\"%s\" CREATE (a)-[:Relation]->(b)' % (x['key'], x['value']['Relation'])))\
.count()\
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

redis-cli HSET marsman:105 Relation marsman:100 # Quaid's workmate (Cohaagen's agent)

read

redis-cli GRAPH.QUERY marsmen "MATCH (n)-[:Relation]->(m) return n.Name, m.Name"


read -p "Back to slides..."

redis-cli HDEL marsman:101 Relation # Quaid killed! Lori 

read

redis-cli GRAPH.QUERY marsmen "MATCH (n)-[:Relation]->(m) return n.Name, m.Name"

read -p "Back to slides..."

######## RedisTimeSeries ############################################################################################ 

redis-cli MODULE LOAD `pwd`/redistimeseries.so

read

# Register for new hearbeat event
redis-cli RG.PYEXECUTE \
"GearsBuilder()\
.foreach(lambda x: execute('TS.ADD', 'heartbeat:'+ x['key'], '*', x['value']['HeartBeat']))\
.register('marsman:*')"

read

for rate in {60..350..15}
do
	redis-cli HSET marsman:100 HeartBeat $rate
	sleep 1
done

for rate in {350..80..30}
do
	redis-cli HSET marsman:100 HeartBeat $rate
	sleep 1
done

read

redis-cli TS.RANGE heartbeat:marsman:100 - + AGGREGATION AVG 5

read -p "Back to slides..."
