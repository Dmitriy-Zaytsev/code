#!/bin/bash
file_ip=/home/dima/DGS_firmw/ip_vlan4.txt
file_scan=/home/dima/DGS_firmw/ip_vlan4_scan.txt
cp $file_ip $file_scan

while read ip
 do
  echo $ip
  ping $ip -l 5 -c 2 -W 1 -D -n &>/dev/null &&  sed "/;"$ip";/ s/$/&;1/g" -i $file_scan ||  sed "/;$ip$/ s/$/&;0/g" -i $file_scan
  nmap -sU -n -p 161 $ip | grep -i '161.*open' &>/dev/null &&  sed "/;"$ip";/ s/$/&;1/g" -i $file_scan ||  sed "/;$ip$/ s/$/&;0/g" -i $file_scan
  nmap -n -p 23 $ip -Pn | grep -i '23.*open' &>/dev/null &&  sed "/;"$ip";/ s/$/&;1/g" -i $file_scan ||  sed "/;$ip$/ s/$/&;0/g" -i $file_scan
 done < <(cat $file_ip | cut -f 2 -d ";" |  sed '1d')
