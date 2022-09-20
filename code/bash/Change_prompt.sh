#!/bin/bash
ip=$1
com='
kp2x45dv8v
ghbitktw
'
logfile=./Change_prompt.log
#new_prompt=$2

script="./Change_prompt.exp"

for community in $com
do
current_prompt=`(snmpget -v 2c -c $community -t 1 -r 0 $ip  sysName.0 -Oqv 2>/dev/null)`
[ "$?" = "0" ] && break
done
echo $current_prompt
read -p "Введите prompt: " new_prompt

echo "$current_prompt --> $new_prompt"
read -p "Продолжить?"

$script $ip $new_prompt

[ "$new_prompt" = `(snmpget -v 2c -c $community $ip  sysName.0 -Oqv 2>/dev/null)` ] && { echo "$ip: $current_prompt --> $new_prompt" >> $logfile;exit 0;}
echo "$ip: $current_prompt --> error" >> $logfile
exit 1
