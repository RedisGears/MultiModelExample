#!/bin/bash -x

redis-cli MODULE LOAD /home/guy/redisconf/RedisGears/redisgears.so

read

redis-cli HSET marsman:100 Name Douglas Last Quaid
redis-cli HSET marsman:101 Name Lori Last Quaid # Quaid's seemingly loving wife

read

#########################################################################################################

redis-cli MODULE LOAD /home/guy/redisconf/RediSearch/src/redisearch.so SAFEMODE

read

redis-cli FT.CREATE marsmen SCHEMA Name Text Last Text

read

redis-cli RG.PYEXECUTE "GearsBuilder().foreach(lambda x: execute('FT.ADDHASH', 'marsmen', x['key'], '1.0', 'REPLACE')).count().run('marsman:*')"

redis-cli RG.PYEXECUTE "GearsBuilder().foreach(lambda x: execute('FT.ADDHASH', 'marsmen', x['key'], '1.0', 'REPLACE')).count().register('marsman:*')"

read

redis-cli HSET marsman:102 Name Vilos Last Cohaagen # Governor of the Mars 
redis-cli HSET marsman:103 Name Bob Last McClane # Rekall manager and sales agent 

read

redis-cli FT.SEARCH marsmen Qu*

read

redis-cli FT.SEARCH marsmen Bob

read

#########################################################################################################

redis-cli MODULE LOAD /home/guy/redisconf/RedisGraph/src/redisgraph.so

read

redis-cli HMSET marsman:101 Married marsman:100

read

redis-cli RG.PYEXECUTE "GearsBuilder().foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MERGE ( :marsman {ID:\"%s\"})' % x['key'])).foreach(lambda x: execute('GRAPH.QUERY', 'marsmen','MATCH ( n:marsman {ID:\"%s\"}) SET n.Name=\"%s\", n.Last=\"%s\"' % (x['key'], x['value']['Name'], x['value']['Last']))).count().run('marsman:*')"

redis-cli RG.PYEXECUTE "GearsBuilder().filter(lambda x: 'Married' in x['value'].keys()).foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MATCH (a:marsman), (b:marsman) where a.ID=\"%s\" AND b.ID=\"%s\" CREATE (a)-[:Married]->(b)' % (x['key'], x['value']['Married']))).run('marsman:*')"

redis-cli RG.PYEXECUTE "GearsBuilder().foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MERGE ( :marsman {ID:\"%s\"})' % x['key'])).foreach(lambda x: execute('GRAPH.QUERY', 'marsmen','MATCH ( n:marsman {ID:\"%s\"}) SET n.Name=\"%s\", n.Last=\"%s\"' % (x['key'], x['value']['Name'], x['value']['Last']))).foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MATCH (a:marsman)-(r)->() where a.ID=\"%s\" DELETE r' % (x['key']))).filter(lambda x: 'Married' in x['value'].keys()).foreach(lambda x: execute('GRAPH.QUERY', 'marsmen', 'MATCH (a:marsman), (b:marsman) where a.ID=\"%s\" AND b.ID=\"%s\" CREATE (a)-[:Married]->(b)' % (x['key'], x['value']['Married']))).count().register('marsman:*')"

read
#########################################################################################################
