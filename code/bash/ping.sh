#!/bin/bash
rm /tmp/ping_* -rf
IP1=192.168.20.20
IP2=10.17.128.1
COUNT=25
SLEEP=15
while true
do
DATE=`(date "+%d-%m-%y_%H-%M-%S")`
ping $IP1 -s 1464 -M do -f -c $COUNT &>/tmp/ping_$DATE.log
ping $IP2 -s 1464 -M do -f -c $COUNT &>>/tmp/ping_$DATE.log
sleep $SLEEP
done
