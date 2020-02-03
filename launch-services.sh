# Launch services if found dead 

#!/bin/bash

for serv in nginx redis-server rabbitmq-server.service mongodb.service mariadb.service neo4j.service elasticsearch.service

do

sstat=$(pgrep $serv | wc -l )

if [ $sstat -gt 0 ]

then

echo "$serv is running!!!"

else

echo "$serv is down/dead"

systemctl start $serv

echo "$serv serv is UP now!!!" 

fi

done
