#!/bin/bash
#Скрипт определяющий получаемые ip от PPPoE сервера.
while true
 do
  killall -9 pppd
  sleep 1
# modprobe  pppoe
  pon pppoe-mts
  sleep 1.2
  ip link show ppp0 && \
  echo "`(ip add show ppp0 | sed -n '/inet/p' | sed 's/.*inet \(.*\) peer.*/\1/g')` | `(date "+%d/%m/%y %H:%M:%S:%N")`" >> ./pppoe_ip.txt || \
  { sleep 10 && continue;}
  poff -a
  sleep 18
# modprobe -r pppoe
 done
