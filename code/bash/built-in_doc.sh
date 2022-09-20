#!/bin/bash
#Можно использовать как словарь.
echo ".................................."
echo "`basename $0` word" - поиск слова.
echo "`basename $0` -s" - вывод документа.
echo ".................................."
if [ "$1" = "-s" ]
  then cat $0 | sed -E -n -e "/^:<<file$/,/$file&/p" | sed -E "/^.*file.*$/d";exit
fi
if [ "$#" != "1" ]
  then echo "Введите одно слово для поиска по внутреннему документу."; exit
  else dic=`(cat $0 | sed -E -n -e "/^:<<file$/,/$file&/p" | grep -w $1)`
fi
if [ "$?" = "0" ]
  then echo "Совпадение найденно."; echo $dic
  else echo "Нет совпадений."
fi

:<<file
work
dima
root
reboot
file
