#!/bin/bash
IP="192.168.33.1
192.168.33.7
192.168.33.13"
COUNT=3
TIME=0.0001


fun () {
echo "START fun"
echo $ip $time
}

OLDIFS=$IFS
IFS=$'\n'
for ip in $(echo "$IP")
 do
  echo -en "$ip...."
  time=`(echo "($(ping -c 3 "$ip" 2>/dev/null | grep from  |  sed -E "s/ {2,3}/ /g" | cut -d " " -f 7 | cut -d "=" -f 2  | tr $'\n' '+' | sed 's/+$//g'))/"$COUNT"" | bc -l 2>/dev/null |  sed 's/^\./0./g' | sed -E 's/(.*\....).*/\1/g')`
  echo "$time"
  [ -z "$time" ] && time=999
  [[ "$(echo "$time > $TIME" | bc -l 2>/dev/null)" = "1" ]] && fun
 done
IFS=$OLDIFS
