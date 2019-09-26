#! /bin/bash

/usr/local/redis/bin/redis-server /usr/local/rediscluster/redis01/redis.conf
/usr/local/redis/bin/redis-server /usr/local/rediscluster/redis02/redis.conf
/usr/local/redis/bin/redis-server /usr/local/rediscluster/redis03/redis.conf
/usr/local/redis/bin/redis-server /usr/local/rediscluster/redis04/redis.conf
/usr/local/redis/bin/redis-server /usr/local/rediscluster/redis05/redis.conf
/usr/local/redis/bin/redis-server /usr/local/rediscluster/redis06/redis.conf

#/usr/local/rediscluster/shell/redis-trib.rb create --replicas 1 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 127.0.0.1:7006
