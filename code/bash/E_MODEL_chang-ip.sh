#!/bin/bash
file=./ip.csv
file_out=./ip_success.csv
file_lock=./log/log.lock
username="sa0405nch"
password="dwGynns5vD"
file_log="./log/LOG.log"

fun_run_script () {
##data=`(./E_MODEL_chang-ip_1.exp $ip_old $ip_new $mask_new $gw_new $username $password 2>&1)`
while true
 do
  sleep 0.1
  if [ ! -f $file_lock ]
    then
     touch $file_lock
     ##echo $data > $file_log
     ./E_MODEL_chang-ip_1.exp $ip_old $ip_new $mask_new $gw_new $username $password 2>&1 >> $file_log
     ret=$?
     [ "$ret" = "0" ] && echo "$ip_old;$ip_new;$mask_new;$gw_new;success" >> $file_out
     [ "$ret" = "10" ] && echo "$ip_old;$ip_new;$mask_new;$gw_new;no_model" >> $file_out
     rm $file_lock
     return 0
  fi
 done
}



if ping -c 1 $1
  then
  ./E_MODEL_chang-ip_1.exp $1 $2 $3 $4 $username $password
  exit 0
fi
#rm $file_out -rf
for line in `(cat $file | sed 's/ /_/g')`
 do
   ip_old=`(echo $line | cut -d ";" -f 1)`
   ping -c 1 $ip_old -w 1 || continue
   ip_new=`(echo  $line | cut -d ";" -f 2)`
   mask_new=`(echo  $line | cut -d ";" -f 3)`
   gw_new=`(echo  $line | cut -d ";" -f 4)`
   #echo "$ip_old;$ip_new;$mask_new;$gw_new" >> $file_out
   ((proc=$proc+1))
    export ip_old ip_new mask_new gw_new
    #fun_run_script & &>/dev/null
    fun_run_script
    (($proc%15)) || { sleep 3;continue;}
    (($proc%75)) || wait
 done
