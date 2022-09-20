#!/bin/bash
file="./ip.csv"
for line in `(cat $file | sed "/^$/d" | sed "s/ /_/g")`
 do
   ip_old=`(echo $line | cut -d ";" -f 1)`
   ip_new=`(echo  $line | cut -d ";" -f 2)`
   mask_new=`(echo  $line | cut -d ";" -f 3)`
   gw_new=`(echo  $line | cut -d ";" -f 4)`
   name=`(echo  $line | cut -d ";" -f 5)`
   ping -c 1 $ip_new -w 1 || continue
  ./E_MODEL_chang-ip_2.exp $ip_new
  echo $?
 done
