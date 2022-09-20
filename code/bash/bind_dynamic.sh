#!/bin/bash
echo "$@" >> /tmp/debug_script.txt
hostip=$1
hostname=$2
zone=$3
keyfile="/etc/bind/Kdnsupdater.+157+07041.private"
configrndc="/etc/rndc.conf"
server=127.0.0.1
ttl=600

oct1=`(echo "$hostip" | cut -d "." -f1 )`
oct2=`(echo "$hostip" | cut -d "." -f2 )`
oct3=`(echo "$hostip" | cut -d "." -f3 )`
oct4=`(echo "$hostip" | cut -d "." -f4 )`

nsupdate -v -k "$keyfile" <<EOF
server $server
update delete $hostname.$zone A
update add $hostname.$zone $ttl A $hostip

update delete $oct4.$oct3.$oct2.$oct1.in-addr.arpa. PTR
update add $oct4.$oct3.$oct2.$oct1.in-addr.arpa. $ttl PTR  $hostname.$zone
send
quit
EOF

rndc -c $configrndc sync
