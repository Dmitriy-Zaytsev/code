#!/bin/bash
file=/home/dima/sw_device.txt #Где ищем.
find=/home/dima/find.csv #Что ищем.
string=; #Строка считаная с $find.
echo ".----." >> $find #Добавив в конец файла, мы сможем определиться когда конец файла(стоит прикратить цикл).
while  [ "$string" != ".----." ]
 do
  read string
# echo "$string - до."
  string=`(echo $string | cut -d ":" -f 2 | sed -E "s/\(.*//g")` #отсикаем лишнее.
# string=`(echo $string | cut -d ":" -f 2 | sed -E "s/-.*//g")` #убрали подъезд.
# echo "$string - после."
  grep $string $file -B 2 2>/dev/null || continue #Если grep что то найдёт(вернёт 0), тогда дальше, нарисуем "......", иначе поднимемся к началу цикла.
  echo "...................."
 done < $find
  sed -i '$d' $find #Удаляем последнию строку.

#Примеры фалов.
#head -n 8 /home/dima/sw_device.txt
#172.19.1.1
#"ES3510MA"
#"nch-mgs02-ou-17_06-1-acsw1"
#......
#172.19.1.2
#"DES-2108 V2.00.08"
#"NG 17/01 - 20"
#......
#
#head -n 2 /home/dima/find.csv
#Port:Name:Status:Vlan:Duplex:Speed:Type:МКУ:Device
#Fa0/1:25/06-0:connected:404:a-full:100:10/100BaseTX:MGS-07:

