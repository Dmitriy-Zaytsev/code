#!/bin/bash
file=./ip_40-03.txt
file_allow=./allow_firm-loader.txt
if [ -n "$1" ]
  then
      grep "^$1;" "$file" > ./ip_one.txt || exit
      file=./ip_one.txt
fi

#script_1="./E_change-firmw.exp"
script_reboot="./E_reboot.exp"
file_lock=$file.lock
rm $file_lock


fun_run_script () {
$script || return 1
while true
 do
  sleep 0.$(($RANDOM % 50))
  if [ ! -f $file_lock ]
    then
     touch $file_lock
     awk  -i inplace 'BEGIN {FS=";";OFS=";"} $1 == "'$ip'" {$5="'$status'"} {print}' $file
     rm $file_lock
     return 0
  fi
 done
}

fun_es3510ma () {
echo $ip $model $firmware $loader
firmware_new="ES3510MA-V1.5.2.7.bix"
script="./`(grep "$model;$firmware;$loader" $file_allow | cut -d ";" -f 4)`"
grep "$model;$firmware;$loader" $file_allow || script=false
port="1/1-8"
script="$script $ip $firmware_new $port"
[[ "$firmware" =~ "$firmware_new" ]] && { awk  -i inplace 'BEGIN {FS=";";OFS=";"} $1 == "'$ip'" {$5="reboot"} {print}' $file; script=true;}
}

fun_ecs3510-2852t () {
echo $ip $model $firmware $loader
firmware_new="ecs3510_28t_v1.5.2.9.bix"
script="./`(grep "$model;$firmware;$loader" $file_allow | cut -d ";" -f 4)`"
grep "$model;$firmware;$loader" $file_allow || script=false
port="1/1-24"; [[ "$model" =~ "52" ]] && port="1/1-48"
script="$script $ip $firmware_new $port"
[[ "$firmware" =~ "$firmware_new" ]] && { awk  -i inplace 'BEGIN {FS=";";OFS=";"} $1 == "'$ip'" {$5="reboot"} {print}' $file; script=true;}
}

fun_es352852m () {
echo $ip $model $firmware $loader
#firmware_new="ES3528_52M_opcode_V1.4.20.29.bix"
firmware_new="ES3528_52M_opcode_V1.4.18.2.bix"
script="./`(grep "$model;$firmware;$loader" $file_allow | cut -d ";" -f 4)`"
grep "$model;$firmware;$loader" $file_allow || script=false
port="1/1-24"; [[ "$model" =~ "52" ]] && port="1/1-48"
script="$script $ip $firmware_new $port"
[[ "$firmware" =~ "$firmware_new" ]] && { awk  -i inplace 'BEGIN {FS=";";OFS=";"} $1 == "'$ip'" {$5="reboot"} {print}' $file; script=true;}
}




proc=0
#download
for data in `(cat $file | grep -v download |  grep -v -i error | grep -v reboot)`
do
 ip=`(echo $data | cut -f 1 -d ";")`
 model=`(echo $data | cut -f 2 -d ";")`
 firmware=`(echo $data | cut -f 3 -d ";")`
 loader=`(echo $data | cut -f 4 -d ";")`
 ping -c 1 $ip &>/dev/null || continue
 ((proc=$proc+1))
 case $model in
  ES3510MA ) fun_es3510ma;;
  ES3528M|ES3552M ) fun_es352852m;;
  ECS3510-28T|ECS3510-52T ) fun_ecs3510-2852t;;
 esac
 export status=download
 export script
 fun_run_script 2>&1 | tee ./temp/"$ip"_download.log || continue
 #(fun_run_script 2>&1 | tee ./temp/"$ip"_download.log &>/dev/null) &
 (($proc%15)) || { sleep 60;continue;}
 (($proc%30)) || wait
done

wait
wait
sleep 5
#reboot
proc=0
for data in `(cat $file | grep download | grep -v reboot | grep -v -i error )`
do
 ip=`(echo $data | cut -f 1 -d ";")`
 model=`(echo $data | cut -f 2 -d ";")`
 firmware=`(echo $data | cut -f 3 -d ";")`
 loader=`(echo $data | cut -f 4 -d ";")`
 ping -c 1 $ip || continue
 ((proc=$proc+1))
 export status=reboot
 export script="$script_reboot $ip"
 fun_run_script 2>&1 | tee ./temp/"$ip"_reboot.log
 #(fun_run_script 2>&1 | tee ./temp/"$ip"_reboot.log) &
 (($proc%15)) || { sleep 15;continue;}
 (($proc%30)) || wait
done
wait
wait
