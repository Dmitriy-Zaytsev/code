#!/bin/bash
#Парсинг друзей в удобном списке.
#1.Заходим на страницу  https://m.vk.com/friends?id=25111031&section=all
#2.Прокручиваем до конца.
#3.Сохраняем как Webpage complete.
#tail -n +14 \ #вывод пропуская первые 13 строк.(Ответы, Новости и.т.д.)
# ./vk_friends.sh "/tmp/Друзья Анастасии Разыграевой.mhtml" #В таком виде надо давать поз.переменную.
OLDIFS=$IFS
IFS=$'\n'
file=$1
cat $file |  sed 's/">/\n/g' | grep '[^^]</a>.*class'  \
| grep -v -i написать | sed 's/<.*//g' \
| tail -n +14 \
| sort -h -k1  | cat -n \
| tr -d ' ' | sed 's/\t/ /g' | cut -f 2 -d " " | sort
IFS=$OLDIFS

