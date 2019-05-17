FROM redislabs/redistimeseries:0.2.0 as redistimeseries
FROM redislabs/redisgraph:1.2.0 as redisgraph
FROM redislabs/redisearch:1.4.8 as redisearch
FROM redislabs/redisgears:0.2.1 as redisgears

ENV LD_LIBRARY_PATH /usr/lib/redis/modules/

COPY --from=redistimeseries /usr/lib/redis/modules/*.so* "$LD_LIBRARY_PATH"
COPY --from=redisgraph /usr/lib/redis/modules/*.so* "$LD_LIBRARY_PATH"
COPY --from=redisearch /usr/lib/redis/modules/*.so* "$LD_LIBRARY_PATH"

WORKDIR /app
ADD . /app

ENTRYPOINT [ "./script.sh" ]
