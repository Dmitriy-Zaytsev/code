#!/bin/bash
file=/tmp/ip.csv
dos2unix $file

for line in `(cat $file)`
  do
   IP_OLD=`(echo $line | cut -d ";" -f 1)`
   IP_NEW=`(echo $line | cut -d ";" -f 2)`
   ./Vendor_Model_change-ip.sh "$IP_OLD" "$IP_NEW" -d
  done
