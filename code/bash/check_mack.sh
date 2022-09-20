#!/bin/bash

IPCheckM=./ip_check_mask.txt
IPCheckA=./ip_check_address.txt
IPDataD=./ip_data_device.txt
ExpectS=./All_command-R-file_ALL.exp


IPCheckAM=./ip_check_address_model.txt


> $IPCheckA
for ip_mask  in `(cat $IPCheckM)`
 do
  #echo "ip_mask: $ip_mask"
  fping -g "$ip_mask" -r 1 -a 2>/dev/null >>$IPCheckA
  echo "."
 done

for ip_add  in `(cat $IPCheckA)`
 do
  sw=`(grep "$ip_add;" $IPDataD | cut -d ";" -f 1-3,6)`
  ip=`(echo "$sw" | cut -d ";" -f 1)`
  vendor=`(echo "$sw" | cut -d ";" -f 2)`
  model=`(echo "$sw" | cut -d ";" -f 3)`
  hostname=`(echo "$sw" | cut -d ";" -f 4 | sed 's;/;_;g')`
  echo "ip_add: $ip_add model: $model vendor: $vendor hostname: $hostname"
  [ -z "$vendor" ] || [ -z "$model" ] && { echo "$ip ERORR: bad vendor or model"; continue;}
  command_file=./"$vendor"_"$model".cmd
  [ -s "$command_file" ] || { touch "$command_file"; echo "$ip ERORR: no cmd file for $model"; break;}
  $ExpectS $ip $command_file | sed 's;/ ;/;' |  grep -E "(Eth |GE|Eth| Dynamic| DeleteOnTimeout)" | \
  grep  -E "([[:xdigit:]]{2,4}[-:.]){2,5}[[:xdigit:]]{2,4}" | \
  sed 's/[\.:-]//g' | tr '[:upper:]' '[:lower:]' |  grep -v "0896adab91" | \
  tr -d '\t' | sed -E -e 's/\ {1,500}/ /g' -e 's/^ //g' | \
  sed -E -e "s;([[:xdigit:]]{12}).*((ge|eth)([[:digit:]]|/){1,10}).*;\1,\2;g" \
  -e "s;.*((ge|eth)([[:digit:]]|/){1,10}).*([[:xdigit:]]{12}).*;\4,\1;g" \
  -e "s;.* ([[:xdigit:]]{12}) ([[:digit:]]{1,2}) .*;\1,\2;g" | \
  sed -E "s;^;$hostname,;g" \
  > "./device/"$ip"_"$hostname".txt"
  $ExpectS $ip $command_file > "./device/"$ip"_"$hostname"_debug.txt"
 done



