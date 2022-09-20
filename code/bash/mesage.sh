#!/bin/bash
#Вывод на все псевдотерминалы сообщения текущего пользователя, проверить возможность 
#получения сообщений терминалом можно с помошью mesg.
pts=; #Псевдо терминалы открытые данным пользователем.
index=; #Номер элемента в массиве pts, отсчёт с 0.
tmp_file="/tmp/mes.txt"
:
if [ "$#" != 1 ]
  then echo "Введите один аргумент или предложение в \"\".";exit 1
fi
echo -e "\n\n\n$1\n\n\n" | tee "$tmp_file"
pts=`(ls -l /dev/pts/* | grep $USER | cut -d " " -f 11)`
pts=($pts)
echo "Открытые pseudoterminal-ы ${pts[*]}".
echo "Количество pseudoterminal-ов ${#pts[*]}".
:
for index in `seq $((${#pts[*]} - 1))`
   do
    tput setaf 1
    write $USER ${pts[index]} <$tmp_file
    tput sgr0
   done
rm $tmp_file
exit 0
