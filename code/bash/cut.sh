#!/bin/bash
file=./ip_cut.txt
file_all=./IP.csv
for ip in `(cat $file | grep -v "^$")`
do
ip_old=`(grep "$ip;" $file_all | cut -d ";" -f 3)`
ip_new=`(grep "$ip;" $file_all | cut -d ";" -f 4)`
mask_new=`( grep "$ip;" $file_all | cut -d ";" -f 5)`
gw_new=`(grep "$ip;" $file_all | cut -d ";" -f 6)`
hostname=`(grep "$ip;" $file_all | cut -d ";" -f 15)`
echo "$ip_old;$ip_new;$mask_new;$gw_new;$model" >> /tmp/IP.txt
ping $ip_old -c 1 -w 1 &>/dev/null || { echo "$ip_old;$ip_new;$mask_new;$gw_new;$model;error";continue;}
./E_MODEL_chang-ip_1.exp $ip_old $ip_new $mask_new $gw_new
echo "$ip_old;$ip_new;$mask_new;$gw_new;$model" >> /tmp/ip.txt
done
