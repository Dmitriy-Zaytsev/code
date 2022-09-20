#!/bin/bash
export DISPLAY XAUTHORITY
file=/tmp/ip.csv
dos2unix $file

for line in `(cat "$file")`
  do
   IP_OLD=`(echo $line | cut -d ";" -f 1)`
   IP_NEW=`(echo $line | cut -d ";" -f 2)`
   MODEL=`(echo $line | cut -d ";" -f 3)`
   MODEL=${MODEL:-model}
   #echo ""$IP_OLD" "$IP_NEW" "$MODEL""
   ./Change_ip_snmpc.sh "$IP_OLD" "$IP_NEW" "$MODEL"
  done
