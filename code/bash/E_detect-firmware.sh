#!/bin/bash
file=./ip_icmp.txt
file_out=./ip_model_2.txt
file_lock=./ip_model_2.txt.lock
rm $file_out -rf
script="./E_define-model-firmware.exp"
fun_run_script () {
data=`($script $ip)`
while true
 do
  sleep 0.1
  if [ ! -f $file_lock ]
    then
     touch $file_lock
     echo $data >> $file_out
     rm $file_lock
     return 0
  fi
 done
}

proc=0
for ip in `(cat $file)`
do
 ping -c 1 $ip || continue
 ((proc=$proc+1))
 export ip
 fun_run_script & &>/dev/null
 (($proc%15)) || { sleep 3;continue;}
 (($proc%75)) || wait
done
