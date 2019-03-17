redis-cli MODULE LOAD /home/guy/redisconf/RedisGears/redisgears.so

redis-cli HSET marsman:100 Name Douglas Last Quaid
redis-cli HSET marsman:101 Name Lori Last Quaid # Quaid's seemingly loving wife

#########################################################################################################

redis-cli MODULE LOAD /home/guy/redisconf/RediSearch/src/redisearch.so SAFEMODE
redis-cli FT.CREATE marsmen SCHEMA Name Text Last Text

redis-cli RG.PYEXECUTE "GearsBuilder().foreach(lambda x: execute('FT.ADDHASH', 'marsmen', x['key'], '1.0', 'REPLACE')).count().run('marsman:*')"

redis-cli RG.PYEXECUTE "GearsBuilder().foreach(lambda x: execute('FT.ADDHASH', 'marsmen', x['key'], '1.0', 'REPLACE')).count().register('marsman:*')"

redis-cli HSET marsman:102 Name Vilos Last Cohaagen # Governor of the Mars 
redis-cli HSET marsman:103 Name Bob Last McClane # Rekall manager and sales agent 

redis-cli FT.SEARCH marsmen Qu*

#########################################################################################################

redis-cli MODULE LOAD /home/guy/redisconf/RedisGraph/src/redisgraph.so

redis-cli HMSET marsman:101 Married marsman:101

redis-cli RG.PYEXECUTE "GearsBuilder().foreach(lambda x: execute('FT.ADDHASH', 'marsmen', x['key'], '1.0', 'REPLACE')).count().run('marsman:*')"

#########################################################################################################
