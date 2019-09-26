#! /bin/bash

/usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 7001 -a redis cluster nodes
