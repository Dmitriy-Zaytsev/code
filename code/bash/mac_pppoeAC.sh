#!/bin/bash
[ ! "$#" = "1" ] && echo "Введите итерфейс." && exit 1
dev=$1
killall tcpdump &>/dev/null
killall pppoe-discovery &>/dev/null
while true
do
echo "........"
( sleep 0.5 && pppoe-discovery -I $dev &>/dev/null ) & &>/dev/null
tcpdump -i eth1.415 ether dst `(cat /sys/class/net/$dev/address)` and ether proto 0x8863 -nn -e -c 15 >/tmp/dumpPADO 2>/dev/null & &>/dev/null sleep 1.5; kill $!
serv=`(cat /tmp/dumpPADO | grep PADO | sed 's/.*\ \(.*\) >.*/\1/g')`
echo -e "MAC PPPoE servers:\n$serv"
echo "........"
read -sn 1
done
