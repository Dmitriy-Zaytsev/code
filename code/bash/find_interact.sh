#!/bin/bash
#Скрипт для поиска адреса (hostnmae) из файла вида,
#...
#ES3510MA nch-ou-MGS43_zyab_15-13_7 172.19.66.197 70:72:cf:6a:99:c9
#ES3510MA nch-ou-ng20/05-4-acsw1 172.19.1.170 70:72:cf:98:d8:45
#ES3510MA nch-ou-ng23_02-acsw1 172.19.3.48 70:72:cf:98:e5:b5
#...
[ -z "$1" ] && echo "NO argumen(file)." && exit
[ ! -f "$1" ] && echo "Unknown file search." && exit
file=$1
echo -e "START SCRIPT.\n"
while true
do
#data=15/14-3
read -t 15 -p "Enter data: " data
[ -z "$data" ] && break
#data=15/14-3,15_14-3,15-14-3,15_14_3
data1=`(echo $data | sed 's/\/\|-\|_/ /g' | cut -d ' ' -f 1)` #komp.
data2=`(echo $data | sed 's/\/\|-\|_/ /g' | cut -d ' ' -f 2)` #dom.
data3=`(echo $data | sed 's/\/\|-\|_/ /g' | cut -d ' ' -f 3)` #podezd.
grep -E $data1\(/\|_\|-\)$data2\(\ \|_\|-\)$data3 $file || echo "Not found."
done
echo -e "\nEXIT SCRIPT."
