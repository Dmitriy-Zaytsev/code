#!/bin/bash
#Скрпит для генерации голоса через google.translate.com
player=;
lang=;
for play in mpg321 mpg123
do
dpkg-query -s "$play" &>/dev/null && player=$play && break
done
[ -z "$player" ] && echo "Не определён плеер." && exit 1

while getopts ":e:r:" Opt
do
 case $Opt in
  e ) lang=en; word=$OPTARG || exit 1;;
  r ) lang=ru; word=$OPTARG || exit 1;;
 esac
done
leng=`(echo "word" | wc -L)`
word=`(echo $word | sed 's/ /\%20/g')`


curl -X GET "translate.google.ru/translate_tts?ie=UTF-8&q="$word"&tl="$lang"&total=1&idx=0&textlen="$leng"&tk=715604|838002&client=t&prev=input" \
-A 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.2.1' 2>/dev/null | $player - &>/dev/null

word=`(echo $word | sed 's/\%20/ /g')`


