#!/bin/bash
file="./ip_dlink121028.txt"
dir="/tmp/`(basename $0)`"
mkdir $dir -p

fun_firmware () {
./D_DES-1210-28_firwmare.exp $ip
sed "/^$ip$/d" $file -i
}

i=0
for ip in `(cat $file)`
 do
 ((i=i+1))
 ping -c 1 -W 1 $ip &>/dev/null || continue
 fun_firmware $ip
#& &>>$dir/$$.log
 (($i%50)) || wait
 done
