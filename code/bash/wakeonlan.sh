#!/bin/bash
[ "$1" = "-h" ] && { echo "`(basename $0)` ip port mac count pause" && exit 0;}
ip=${1:-172.16.0.2}
port=${2:-9}
mac=${3:-40:16:7e:a6:fe:67}
max_count=${4:-180}
pause=${5:-10}


echo "Будим ip:$ip port_udp:$port mac:$mac count:$max_count"
count=1

while [[ "$count" -le "$max_count" ]]; do echo "Попытка разбудить $count";wakeonlan -i 172.16.0.2 -p 9  40:16:7e:a6:fe:67;((count=count+1)) ;sleep $pause;done

