#!/bin/sh

if [ "$REDIS_PASSWORD"x != ""x ]
then
    echo "Use Password"
    echo "requirepass ${REDIS_PASSWORD}">>/usr/bin/redis.conf
elif [ "$ALLOW_EMPTY_PASSWORD"x = "yes"x ]
then
    echo "Allow Empty Passowrd"
else
    echo "No ENV Set For REDIS_PASSWORD or ALLOW_EMPTY_PASSWORD"
fi

redis-server /usr/bin/redis.conf