# Stop services if running

#!/bin/bash

for serv in nginx redis-server rabbitmq-server.service mongodb.service mariadb.service neo4j.service elasticsearch.service

do

sstat=$(pgrep $serv | wc -l )

if [ $sstat -lt 0 ]

then

echo "$serv is down/dead"

else

echo "$serv is running"

systemctl stop $serv

echo "$serv serv is down/dead" 

fi

done
