#! /bin/bash

/usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 7001 -a redis shutdown
/usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 7002 -a redis shutdown
/usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 7003 -a redis shutdown
/usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 7004 -a redis shutdown
/usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 7005 -a redis shutdown
/usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 7006 -a redis shutdown
