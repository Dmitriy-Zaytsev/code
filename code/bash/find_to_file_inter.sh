#!/bin/bash
#Поиск по файлу в интерактивном режиме.
inkey=1
file=${1:-~/sw_device.txt} #Если не введён аргумент тогда $file примет значение ~/sw_device.txt.
if [ ! -f "$file" ]
  then echo "Укажите файл."
  exit
fi
echo "Поиск по файлу $file ."
echo "-----------"
while [ "$inkey" != "" ]
  do
   read inkey
   inkey=`(echo $inkey | sed -E 's/\./\\\./g')` #заменим . на \. для grep -E.
   grep -E -w $inkey $file -A2 || continue
   echo "-----------"
done


#cat ./sw_device.txt
#......
#172.19.7.59
#DGS-1100-08
#r2-45/01-12sw1
#......
#172.19.7.60
#DGS-1100-08
#r3-45/01-12sw1
#......

