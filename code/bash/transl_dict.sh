#!/bin/bash
#verbose=1; set -x #для отладки скрипта =1.
fun_debug () {
message=$1
fun_name=$2
[ "$verbose" = "1" ] && echo -e ""$message" "$fun_name"." || return 0
[ -z "$fun_name" ] && return 0
if [[ "$message" =~ "Старт" ]]
  then
   unset time_stop_$fun_name ; eval time_start_$fun_name=$(date +%s%3N)
  elif [[ "$message" =~ "Конец" ]]
      then
       eval time_stop_$fun_name=$(date +%s%3N)
       let  time_perf=`(eval echo "$"time_stop_$fun_name)`-`(eval echo "$"time_start_$fun_name)`
       echo "+DEBUG: Время исполнения "$fun_name" "$time_perf" миллисекунды."
fi
}

fun_debug "+DEBUG: Начало скрипта."

fun_debug "+DEBUG: Переменные."
#Не все переменные описаны.
#Части речи.
#noun -- существительное.В массиве part ${part[0]}.
#verb -- глагол. ${part[1]}.
#adjective -- прилагательное. ${part[2]}.
#adverb -- наречие. ${part[3]}.
#pronoun -- местоимение. ${part[4]}.
#particle -- частица. ${part[5]}.
#preposition -- предлог. ${part[6]}.
#conjunction -- союз. ${part[7]}.
#article -- артикль. ${part[8]}.
index="" #номер элемента в массиве part.
part="noun verb adjective adverb pronoun particle preposition conjunction article" #части речи.
part=($part) #записываем всё что в part обратно в part, но уже как массив.
variant=3 #max количество выдаваемое при переводе для каждой части речи.
no_transl=1 #Если найдено хоть одна часть речи примет значение 0.
failtrans="" #возможное слово, при неверном вводе.
failtrans2="" #похожие слова при неверном переводе.

#Цвета.
yellow='\e[0;33m'; yellowU='\e[4;33m'; yellowB='\e[1;33m'
red='\e[0;31m'; redU='\e[4;31m'; redB='\e[1;31m'
green='\e[0;32m'; greenU='\e[4;32m'; greenB='\e[1;32m'
cyan='\e[0;36m'; cyanU='\e[4;36m'; cyanB='\e[1;36m'
blue='\e[0;34m'; blueU='\e[4;34m'; blueB='\e[1;34m'
rescol='\e[0m'
Cword_of="" #Цвет введёного слова.
Cword_in="" #Цвет переведёного слова.


word="" #слово которое мы ввели.
word2="" #слово которое переводит google,при правелном написании совпадают.
word_loop=; #слово для перевода в петле.
accent="" #произношение, транскрипция.
lang_of="" #с какого.
lang_in="" #в какой переводим язык.

#Нужные пакеты.
packages_inst='
curl
libc-bin
xsel
mpg321
libnotify-bin
dunst
gawk
'
arg=; #Аргумент переданный скрипту(после указания ключа).


#Директории и файлы.
script_name=`(basename $0)`
tmpfile=`(tempfile)`
work_dir=~/${script_name%.*}
audio_dir=""$work_dir"/voice"
dict_txt=""$work_dir"/dict.txt" #для верной проверки в файлах должен присутствовать *.txt.
header_dict="eng#rus#accent#bal#date" #шапка словаря при выводе (-d list)
header_print="eng#rus#accent" #шапка при распечатовании слов.

#Оценка перевода.
def_bal=0 #при занесении слова по умолчанию балов.
max_bal=30 #если превысит эту отметку слово будет считаться изученным.
erro_bal=2 #при ошибки ответа уменьшим на 2-а бала.
true_bal=1

#Проверка уст.пакетов.
fun_check_package () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
for package in $packages_inst
do
 ! dpkg-query -s "$package" &>/dev/null &&  { echo "Не установлен $package."; exit 2;}
done
echo "Проверка установленных пакетов прошла успешно."
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}


#Проверка директорий и файлов.
fun_check_file_dir () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
for i  in $work_dir $audio_dir $dict_txt
do
if [[ "$i" =~ "txt" ]] && [[ ! -e "$i" ]]
 then
  touch "$i" || exit 2
  echo -e ""$redB"Создан файл "$i.""$rescol""
 else
  if [[ ! -e "$i" ]]
   then
     mkdir -p $i || { echo "Ошибка в создании $i" && exit 2;}
     echo -e ""$redB"Создана директория "$i.""$rescol""
  fi
fi
[ ! -r "$i" ] && { echo "Нет прав на чтение $i." && exit 2;}
[ ! -w "$i" ] && { echo "Нет прав на запись $i." && exit 2;}
done
find "$audio_dir" -size -1k -delete &>/dev/null
echo "Проверка файлов и директорий прошла успешно."
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}


###################################
#Перевод через google.translate.ru#
fun_word_get () {
fun_genTK "$word"
word=`(echo $word | sed 's/ /\%20/g')`
word_get=`(curl -s -A "Mozilla/5.0 (X11; Linux x86_64; rv:40.0) Gecko/20100101 Firefox/40.0" --header "Host: translate.google.com"  --header "Connection: close" -G "https://translate.google.com/translate_a/single?client=t&ie=UTF-8&oe=UTF-8&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&sl="$lang_of"&tl="$lang_in"&hl=en&tk="$tk"&q="$word"" -v 2>/dev/null)`
word=`(echo $word | sed 's/\%20/ /g')` #обратно меняем на пробелы.
word2=`(echo $word_get | sed -E "s/.*\[\[\[\".*\",\"(.*)\",,,.\],\[,,.*/\1/g" | grep -E -v '\[\[')`
[ -z "$word2" ] && word2=$word
}


fun_trans_google () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
unset lang_of lang_in Cword_in Cword_of
ping google.com -W 1 -c 1 -s 1 &>/dev/null  || { echo "Сервер google не доступен" && exit 2;}
word="$1"
#Определение языка переводимого слова.
word=`(echo $word | sed 's/[[:upper:]]*/\L&/')`
case $word in #условие проверяется посимвольно.
          *[a-z]*[а-я]* ) lang_of="";; #латиница вместе с кириллицой.
          *[а-я]*[a-z]* ) lang_of="";; #кириллица вместе с латиницей.
          *[!=а-я]* ) lang_of=en;lang_in=ru;Cword_of="$greenU"; Cword_in="$yellow" ;;
          *[!=a-z]* ) lang_of=ru;lang_in=en;Cword_of="$yellowU"; Cword_in="$green" ;;
         esac
[ -z "$lang_of" ] && echo "Не определён язык перевода." && return 2
unset accent word_get
fun_word_get
export word_get
#accent=`(echo $word_get | tr -d $'\x9e' | tr -d $'\xcd' | sed 's/\],/&\n/g' | sed -n '2p' | sed  -E "s/.*\",\"(.*)\"\]\],$/\1/g" | grep -v -E ".*\[.*\]\].*")`
fun_get_accent
#Замена символов из за не правельного отображения шрифтом терминуса.
#accent=`(echo $accent | sed -E "s/ˈ/'/g" | sed -E "s/ˌ/,/g")`
#для проверки.
#echo $word_get > /tmp/dict.txt

echo -en "$cyan"$lang_of"-"$lang_in"$rescol  $Cword_of"$word"$rescol"
[ ! "$word" = "$word2" ] && { [ ! -z "$word2" ] &&  echo -en "$Cword_of("$word2")$rescol";}
[ -n "$accent" ] && echo -en "  $redB"$accent"$rescol"
echo -en "\n"

#Парсим get запрос по частям речи которые в массиве.
no_transl=1
for index in `seq 0 $((${#part[@]} - 1))`
do
####echo -e "\n\n\n\n\n\n---\n"
#####echo $word_get
######echo -e "\n\n\n\n\n\n---\n"
word_out=`(echo "$word_get" | sed "s/\"${part[$index]}\"\,\[\"/\n/" | sed  -n '2p' | sed 's/\"\]/\n/' | sed  -n '1p' | sed 's/"//g' | cut -d "," -f1-$variant | sed 's/$/./')`
 if [ ! -z "$word_out" ]
    then
        case $index in
            0 )  no_transl=0; echo -e "имя существительное: $Cword_in"$word_out"$rescol";;
            1 )  no_transl=0; echo -e "глагол: $Cword_in"$word_out"$rescol";;
            2 )  no_transl=0; echo -e "имя прилагательное: $Cword_in"$word_out"$rescol";;
            3 )  no_transl=0; echo -e "наречие: $Cword_in"$word_out"$rescol";;
            4 )  no_transl=0; echo -e "местоимение: $Cword_in"$word_out"$rescol";;
            5 )  no_transl=0; echo -e "частица: $Cword_in"$word_out"$rescol";;
            6 )  no_transl=0; echo -e "предлог: $Cword_in"$word_out"$rescol";;
            7 )  no_transl=0; echo -e "союз: $Cword_in"$word_out"$rescol";;
            8 )  no_transl=0; echo -e "артикль: $Cword_in"$word_out"$rescol";;
        esac
 fi
done
#Допустим при переводе links лучше всегда искать перевод без указания части речи.
 ##if [ "$no_transl" = "1" ] #т.е. не была найдена не одна из частей речи.
 if [ "1" = "1" ] #т.е. не была найдена не одна из частей речи.
    then
        word_out=`(echo "$word_get" | sed 's/\[\[\[\"/\n/' | sed  -n '2p' | sed 's/\"\,\"/\n/' | sed  -n '1p' | sed 's/"//g' | cut -f1 | sed 's/$/./' | grep -E -v "\[\[")`
        word=`(echo $word. | sed 's/\%20/ /g')` # добавили точку в конце слова и переведём их формата get запроса в обычный для сравнения(слово%20слово в слово слово").
        #Если перевод не пустой, не равен переводимому, и в полученной странице нет [[["$word"-признак что возможно не верно написано слово, так как там должен был быть перевод.
        if [ ! -z "$word_out" ] && [ "$word_out" != "$word" ] && ! `(echo "$word_get" | grep -q  "\[\[\[\"$word\"")`
           then echo -e "$Cword_in"$word_out"$rescol"; no_transl=0
               failtrans=`(echo "$word_get" | sed -E "s/.*,\"(.*)\",\[1\],,,false.*/\1/g" | grep -v '\[\[\[')`
               [ -z "$failtrans" ]  || echo -e "Возможно вы имели в виду $redU"$failtrans"$rescol"

           else echo -en  "Перевод не найден."
               failtrans=`(echo "$word_get" | sed -E "s/.*,\"(.*)\",\[1\],,,false.*/\1/g" | grep -v '\[\[\[')`
               [ -z "$failtrans" ]  || echo -e "\nВозможно вы имели в виду $redU"$failtrans"$rescol"
        fi
 fi
#Аудио произношение.
[[ "$lang_of" = "en" ]] && { [[ "$no_transl" = "0" ]] && { [[ -z "$failtrans" ]] && fun_voice;};}
failtrans2=`( echo "$word_get" | sed -E "s/.*\[\[\"(.*)\"\]\]\].*/\1/g" | grep -v '\[' | grep -v '\]' | grep -v '"')`
[ -z "$failtrans2" ]  || echo -e "Похожие слова $redU"$failtrans2"$rescol"


fun_dict_show "$word2" "quiet"
}
###################################

fun_voice () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
mp3="$audio_dir/`(echo $word2 | sed 's/ /_/g')`.mp3"
word2=`(echo $word2 | sed 's/ /\%20/g')`
leng=`(echo "word" | wc -L)`
find $mp3 &>/dev/null || \
curl -X GET "https://translate.google.com/translate_tts?ie=UTF-8&q="$word2"&tl=en&total=1&idx=0&textlen="$leng"&tk="$tk"&client=t" \
-A 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.2.1' -v >$mp3 2>/dev/null
mpg321 "$mp3" &>/dev/null &
word2=`(echo $word2 | sed 's/\%20/ /g')`
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

#Вывод черед notification(dunst).
fun_notification () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
#Для того чтобы не выводились не нужные символы раскраски для dunst, также по pipe можно прогнать через  tr -d '[:xdigit:]'
unset yellow yellowU yellowB red redU redB green greenU greenB cyan cyanU cyanB blue blueU blueB rescol
#Добавляем в конце строки \n для того что бы dunst переносил строки по этому символу,
#убираем перенос строк, и добовляем только в конец строк.
#Можно  забиндить transl_dict.sh  -n "`(xsel -o | xsel -i && xsel -o)`"
#fun_trans_google $1 | sed 's/$/\\\\n/g' | tr -d $'\x0a' | xargs -i notify-send -u low {}
fun_trans_google "$1" | sed 's/$/\\n/g' | tr -d $'\x0a' | sed 's/$/\n/g' > $tmpfile
notify-send -u normal "$(cat $tmpfile)" -t 12000  -i /usr/share/icons/gnome/32x32/emblems/emblem-new.png
#Для старого dunst, проблема с переводом строки.
#cat $tmpfile | xargs -i notify-send -u low "{}" -t 3000
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}


fun_trans_loop () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
word_loop="word"
while [ -n "$word_loop" ]
do
read -p "Введите переводимое слово " word_loop
test -n "$word_loop" && fun_trans_google "$word_loop"
done
return 0
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

#Вывод локального словаря в виде таблицы.
fun_dict_list () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
#Максимальная длина форматированного текста.
fun_dict_list_in () {
max_string=`((echo "$header_dict";cat "$dict_txt")  |  sed -E "s/#/\!&\!/g" | sed -e 's/^/#!/g' -e 's/$/!#/g' | column -t -s "!" | sed -e 's/ # /|/g' -e 's/^# /|/g' -e 's/ #$/|/g' | wc -L)`
#Шапка.
cat /dev/zero | head -c "$max_string" | tr '\0' '_';
echo
(echo "$header_dict"; cat "$dict_txt") |  sed -E "s/#/\!&\!/g" | sed -e 's/^/#!/g' -e 's/$/!#/g' | column -t -s "!" | sed -e 's/ # /|/g' -e 's/^# /|/g' -e 's/ #$/|/g' | head -n 1
cat /dev/zero | head -c "$max_string" | tr '\0' '+';
echo
(echo "$header_dict"; cat "$dict_txt") |  sed -E "s/#/\!&\!/g" | sed -e 's/^/#!/g' -e 's/$/!#/g' | column -t -s "!" |  sed '1d'  | sed -e 's/ # /|/g' -e 's/^# /|/g' -e 's/ #$/|/g' | sort -t "|" -k1 -h
cat /dev/zero | head -c "$max_string" | tr '\0' '-';
echo
}
#fun | less
fun_dict_list_in
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

#Сброс счётчиков.
fun_dict_clear_bal () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
read -p "Сбросить балы в словаре(yes/NO) " key
[ ! "$key" = "yes" ] && return 0
awk -i inplace 'BEGIN {FS="#"; OFS="#";} /^.*#/ {if($4 != 0) $4="'"$def_bal"'";print;}' "$dict_txt"
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

#Разбор строки
fun_dict_train_string () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
eng=`(echo "$string" | cut -d"#" -f1)`
ru=`(echo "$string" | cut -d"#" -f2)`
ru1=`(echo "$ru" | cut -d"," -f1)`
ru2=`(echo "$ru" | cut -d"," -f2)`
ru3=`(echo "$ru" | cut -d"," -f3)`
accent=`(echo "$string" | cut -d"#" -f3)`
bal=`(echo "$string" | cut -d"#" -f4)`
date=`(echo "$string" | cut -d"#" -f5)`
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}


#Тренировка по словарю.
fun_dict_train  () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
> "$tmpfile"
#Формирование словоря для слов которые не достигли запоминания.
while read string
do
fun_dict_train_string
if [[ "$bal" -ge "$max_bal" ]]
  then
    echo -e ""$green"Cлово считается заученым: "$greenU"$eng -#- $ru"$rescol""
  else
    echo ""$eng"#"$ru"#"$accent"#"$bal"#"$date"" >> "$tmpfile"
fi
done < "$dict_txt"
max_line=`(cat "$tmpfile" | wc -l)`
while true
  do
   rand_line=$(($RANDOM % $max_line + 1))
   string=`(sed -n ""$rand_line"p" "$tmpfile")`
   fun_debug "+DEBUG: Рандомная строка $string"
   fun_dict_train_string
   #Подсчёт запятых, т.е. разделителей для rus слов.Если 0 тогда одно слово.
   numb_ru=$((`(echo "$ru" | grep -o ',' | wc -l)`+1))
   max_numb_ru="$numb_ru"
   true=0
   while [ "$max_numb_ru" -ge 1  ]
     do
      echo -e "Введите перевод слова "$greenU""$eng""$rescol" "$accent" x"$max_numb_ru""
      read rus_ent
      suffix=1
      for rus_name_var in "ru1" "ru2" "ru3"
        do
         rus_dict=${!rus_name_var}
         if [[ ! -z "$rus_ent" ]] && [[ "$rus_ent" = "$rus_dict" ]]
           then
            #Обнуляем уже переведённое слово, что бы введя повторно не защиталось за верный ввод.
            declare ru$suffix=;
            echo "Введёное слово верное." && { ((true=$true+1)); break;}
         fi
         ((suffix=$suffix+1))
        done
      ((max_numb_ru="$max_numb_ru"-1))
     done
     #Подсчёт балов, если все варианты были верными то +1.
     [ "$true" = "$numb_ru" ] && ((bal=$bal+$true_bal)) || ((bal=$bal-$erro_bal))
     awk -i inplace 'BEGIN { FS = "#";OFS = "#" }'"/^$eng#/"'{$4="'"$bal"'"}{print;}' "$dict_txt"
  done
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

#Поиск по локальному словарю.
fun_dict_show () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
word=$1
[ -z "$word" ] && return 1
q=0 #Более болтливый режим.
message=;
[ "$2" = "quiet" ] && { export q=1 && message="\nПоиск по локальному словарю.\n";}
var_grep=`(grep -i "^$word#" ./transl_dict/dict.txt | cut -d"#" -f1,2 | sed 's/#/ -&- /g')`
test -n "$var_grep" && { echo -e ""$message""$green"Перевод:"$rescol"\n"$var_grep"";} || \
{ [ "$q" = "0" ] && echo -e ""$red"Перевод не найден."$rescol"";}
unset var_grep
var_grep=`(grep -E "^.*$word.*#" "$dict_txt" | grep -i -v "^$word#" | cut -d"#" -f1,2 | sed 's/#/ -&- /g')`
test -n "$var_grep" && echo -e ""$message""$yellow"Похожие слова:"$rescol"\n"$var_grep""
unset var_grep
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}


#Проверка слов при добавлении и удалении слов со словоря.
fun_check_lang_dict () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
case $word_en in #условие проверяется посимвольно.
          *[a-z]*[а-я]* ) lang_of="";; #латиница вместе с кириллицой.
          *[а-я]*[a-z]* ) lang_of="";; #кириллица вместе с латиницей.
          *[!=а-я]* ) lang_of=en;;
         esac
case $word_ru in #условие проверяется посимвольно.
          *[a-z]*[а-я]* ) lang_in="";; #латиница вместе с кириллицой.
          *[а-я]*[a-z]* ) lang_in="";; #кириллица вместе с латиницей.
          *[!=a-z]* ) lang_in=ru;
         esac
[ "x$lang_of" = "xen" -a "x$lang_in" = "xru" ] || { echo  -e ""$redB"Проверьте правильност написания слова и перевода."$rescol"" && return 2;}
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}


#Удаление анг. слова со словоря.
fun_dict_del () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
word_en=$1
word_en=`(echo $word_en | sed 's/[[:upper:]]*/\L&/')`
lang_in=ru #так как мы не вводим перевод, а удаляем.
fun_check_lang_dict || return 1
var_grep=`(grep -E "^.*$word_en.*#" "$dict_txt" | grep -v -i "^$word_en#")`
test -n "$var_grep" && echo -e ""$yellow"Похожие слова:"$rescol" \n "$var_grep""
unset var_grep
var_grep=`(grep -E "^"$word_en"#" "$dict_txt")`
test ! -n "$var_grep" && echo -e ""$redB"Данного слова нет в словаре."$rescol"" && return 0
read -n 1 -p "Удалить слово со словаря(y/N)?  " key
[ ! "$key" = "y" ] && return 0
sed -E "/^"$word_en"#/d" -i "$dict_txt"
echo -e "\n"$greenB"Удалено слово "$word_en"."$rescol""
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

#Для получения транскрипции при добавление слова в словарь.
fun_get_accent () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
ping google.com -W 1 -c 1 -s 1 &>/dev/null  || echo -e ""$redB"Сервер google не доступен для получения транскрипции."$rescol""
if [ -z "$word_get" ]
 then
 fun_word_get
fi
word2=`(echo $word_get | sed -E "s/.*\[\[\[\".*\",\"(.*)\",,,.\],\[,,.*/\1/g" | grep -E -v '\[\[')`
[ -z "$word2" ] && word2=$word
export word_get
accent=`(echo $word_get | sed 's/\],/&\n/g' | sed -n '2p' | sed  -E "s/.*\",\"(.*)\"\]\],$/\1/g" | grep -v -E ".*\[.*\]\].*" | grep -E -v '\[\[')`

[ -z "$accent" ] && accent="_"
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

#Добавление слова в словарь(только с анг. на рус.).
fun_dict_add  () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
word_en=$1
word_en=`(echo $word_en | sed 's/[[:upper:]]*/\L&/')`
shift
word_ru=$@
word_ru=`(echo "$word_ru" | sed -E "s/\ {2,99}/\,/g" | cut -f1-"$variant" -d ",")`
fun_check_lang_dict || return 0
var_grep=`(grep "^$word_en#" "$dict_txt" 2>/dev/null)`
test -n "$var_grep" && { echo -e ""$redB"Перевод данного слова имеется в словаре:"$rescol" $var_grep" && return 2;}
unset var_grep
var_grep=`(grep -E "^.*$word_en.*#" "$dict_txt" 2>/dev/null | grep -v -i "^$word_en#")`
test -n "$var_grep" && echo -e ""$yellow"Похожие слова:"$rescol" \n$var_grep"
unset accent
word="$word_en"
fun_get_accent
echo "$word_en#$word_ru#$accent#$def_bal#`(date "+%Y.%m.%d")`" >> $dict_txt
echo -e ""$green"Cлово добавленно в словарь."$rescol""
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}


#Разбор параметров для работы с локальным словарём.
fun_dictionary () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
arg=$1
shift 1
case $arg in
  add ) fun_dict_add "$@"; return 0;;
 list ) fun_dict_list; return 0 ;;
  del ) fun_dict_del "$@"; return 0;;
 show ) fun_dict_show "$@"; return 0;;
train ) fun_dict_train ;return 0;;
res_bal) fun_dict_clear_bal; return 0;;
    * ) echo "Не определены параметры для ключа -d(локальный словарь)." && exit 1;;
esac
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}


fun_print_dict  () {
printer=`(lpstat -p | sed -n '/printer/s/^printer \(\S*\) .*/\1/gp')`
fun_print_dict_in () {
max_string=`((echo "$header_print";cat "$dict_txt" | cut -f1-3 -d "#")  |  sed -E "s/#/\!&\!/g" | sed -e 's/^/#!/g' -e 's/$/!#/g' | column -t -s "!" | sed -e 's/ # /|/g' -e 's/^# /|/g' -e 's/ #$/|/g' | wc -L)`
#Шапка.
cat /dev/zero | head -c "$max_string" | tr '\0' '_';
echo
(echo "$header_print";cat "$dict_txt"  | cut -f1-3 -d "#") |  sed -E "s/#/\!&\!/g" | sed -e 's/^/#!/g' -e 's/$/!#/g' | column -t -s "!" | sed -e 's/ # /|/g' -e 's/^# /|/g' -e 's/ #$/|/g' | head -n 1
cat /dev/zero | head -c "$max_string" | tr '\0' '+';
echo
(cat "$dict_txt" | cut -f1-3 -d "#") | sed -E "s/#/\!&\!/g" | sed -e 's/^/#!/g' -e 's/$/!#/g' | column -t -s "!" | sed -e 's/ # /|/g' -e 's/^# /|/g' -e 's/ #$/|/g' | sort -t "|" -k1 -h | sed "s/$/\n$( yes - | head -c $max_string | tr '\n' ' ')/g" | sed '$d'
cat /dev/zero | head -c "$max_string" | tr '\0' '-';
echo
}
echo "Печать на принтер $printer..."
fun_print_dict_in | lp -d $printer
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

fun_help () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
scr_name=`(basename $0)`
echo "
--------------------------------------------------HELP--------------------------------------------------
"$script_name" -t word - перевести слово и вывести(транскрипция,произношение) в stdout.\n   Так же если слово будет покажет в лок.слов.
"$script_name" -i - аналогично -t , но перевод в цикле.
"$script_name" -n word - перевести слово и вывести(транскрипция,произношение) через notify-send(dunst).
"$script_name" -p - печать всего словаря.
"$script_name" -d работа с локальным словарём add|list|del|show|train.....
    add - добавить слово. -d add work работа работать работать,труд
    list - вывести словарь в табличном виде.
    del - удалить слово со словоря.
    show - поиск слова в локальном словаре.
    train - (training) тренировка по словарю.
    res_bal - сброс балов.
"$script_name" -c проверка установленных пакетов и наличие/чтение/запись файлов/директорий.
--------------------------------------------------------------------------------------------------------"
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

#Проверка для ключей без параметров, например -i, для того что бы он
#не взял следующий ключь как аргумент для первого.
check_arg_getopts () {
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
[[ "$OPTARG" =~ - ]] && unset OPTARG && ((OPTIND=OPTIND-1))
#export OPTARG
#export OPTIND
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}

fun_genTK () {
#Кусок взят с https://github.com/soimort/translate-shell для генерации числа(tk) для get
#запроса, не получилось до конца понять как его получают. tk меняеться в зависимости слово+текущий час даты.
fun_debug "+DEBUG: Старт функции " "$FUNCNAME"
#Позже передадим переменную gawk-у.
read -r -d '' VAR_READ << 'EOF'

function initConst() {
NULLSTR = ""
STDIN  = "/dev/stdin"
STDOUT = "/dev/stdout"
STDERR = "/dev/stderr"
SUPOUT = " > /dev/null "
SUPERR = " 2> /dev/null "
PIPE = " | "
}

function l(value, name, inline, heredoc, valOnly, numSub, sortedIn) {
if (Option["debug"]) {
if (name)
da(value, name, inline, heredoc, valOnly, numSub, sortedIn)
else
d(value)
}
}

function parseList(returnAST, tokens,
leftBrackets,
rightBrackets,
separators,
i, j, key, p, stack, token) {
if (!leftBrackets[0]) {
leftBrackets[0] = "("
leftBrackets[1] = "["
leftBrackets[2] = "{"
}
if (!rightBrackets[0]) {
rightBrackets[0] = ")"
rightBrackets[1] = "]"
rightBrackets[2] = "}"
}
if (!separators[0]) {
separators[0] = ","
}
stack[p = 0] = 0
for (i = 0; i < length(tokens); i++) {
token = tokens[i]
if (belongsTo(token, leftBrackets)) {
stack[++p] = 0
} else if (belongsTo(token, rightBrackets)) {
stack[--p]++
} else if (belongsTo(token, separators)) {
} else {
key = NULLSTR
if (p > 0) {
for (j = 0; j < p - 1; j++)
key = key SUBSEP stack[j]
returnAST[key][stack[p - 1]] = NULLSTR
key = key SUBSEP stack[p - 1]
}
returnAST[key][stack[p]] = token
stack[p]++
}
}
}


function matchesAny(string, patterns,
i) {
for (i in patterns)
if (string ~ "^" patterns[i]) return patterns[i]
return NULLSTR
}


function startsWithAny(string, substrings,
i) {
for (i in substrings)
if (index(string, substrings[i]) == 1) return substrings[i]
return NULLSTR
}


function belongsTo(element, array,
i) {
for (i in array)
if (element == array[i]) return element
return NULLSTR
}

function tokenize(returnTokens, string,
delimiters,
newlines,
quotes,
escapeChars,
leftBlockComments,
rightBlockComments,
lineComments,
reservedOperators,
reservedPatterns,
blockCommenting,
c,
currentToken,
escaping,
i,
lineCommenting,
p,
quoting,
r,
s,
tempGroup,
tempPattern,
tempString) {
if (!delimiters[0]) {
delimiters[0] = " "
delimiters[1] = "\t"
delimiters[2] = "\v"
}
if (!newlines[0]) {
newlines[0] = "\n"
newlines[1] = "\r"
}
if (!quotes[0]) {
quotes[0] = "\""
}
if (!escapeChars[0]) {
escapeChars[0] = "\\"
}
if (!leftBlockComments[0]) {
leftBlockComments[0] = "#|"
leftBlockComments[1] = "/*"
leftBlockComments[2] = "(*"
}
if (!rightBlockComments[0]) {
rightBlockComments[0] = "|#"
rightBlockComments[1] = "*/"
rightBlockComments[2] = "*)"
}
if (!lineComments[0]) {
lineComments[0] = ";"
lineComments[1] = "//"
lineComments[2] = "#"
}
if (!reservedOperators[0]) {
reservedOperators[0] = "("
reservedOperators[1] = ")"
reservedOperators[2] = "["
reservedOperators[3] = "]"
reservedOperators[4] = "{"
reservedOperators[5] = "}"
reservedOperators[6] = ","
}
if (!reservedPatterns[0]) {
reservedPatterns[0] = "[+-]?((0|[1-9][0-9]*)|[.][0-9]*|(0|[1-9][0-9]*)[.][0-9]*)([Ee][+-]?[0-9]+)?"
reservedPatterns[1] = "[+-]?0[0-7]+([.][0-7]*)?"
reservedPatterns[2] = "[+-]?0[Xx][0-9A-Fa-f]+([.][0-9A-Fa-f]*)?"
}
split(string, s, "")
currentToken = ""
quoting = escaping = blockCommenting = lineCommenting = 0
p = 0
i = 1
while (i <= length(s)) {
c = s[i]
r = substr(string, i)
if (blockCommenting) {
if (tempString = startsWithAny(r, rightBlockComments))
blockCommenting = 0
i++
} else if (lineCommenting) {
if (belongsTo(c, newlines))
lineCommenting = 0
i++
} else if (quoting) {
currentToken = currentToken c
if (escaping) {
escaping = 0
} else {
if (belongsTo(c, quotes)) {
if (currentToken) {
returnTokens[p++] = currentToken
currentToken = ""
}
quoting = 0
} else if (belongsTo(c, escapeChars)) {
escaping = 1
} else {
}
}
i++
} else {
if (belongsTo(c, delimiters) || belongsTo(c, newlines)) {
if (currentToken) {
returnTokens[p++] = currentToken
currentToken = ""
}
i++
} else if (belongsTo(c, quotes)) {
if (currentToken) {
returnTokens[p++] = currentToken
}
currentToken = c
quoting = 1
i++
} else if (tempString = startsWithAny(r, leftBlockComments)) {
if (currentToken) {
returnTokens[p++] = currentToken
currentToken = ""
}
blockCommenting = 1
i += length(tempString)
} else if (tempString = startsWithAny(r, lineComments)) {
if (currentToken) {
returnTokens[p++] = currentToken
currentToken = ""
}
lineCommenting = 1
i += length(tempString)
} else if (tempString = startsWithAny(r, reservedOperators)) {
if (currentToken) {
returnTokens[p++] = currentToken
currentToken = ""
}
returnTokens[p++] = tempString
i += length(tempString)
} else if (tempPattern = matchesAny(r, reservedPatterns)) {
if (currentToken) {
returnTokens[p++] = currentToken
currentToken = ""
}
match(r, "^" tempPattern, tempGroup)
returnTokens[p++] = tempGroup[0]
i += length(tempGroup[0])
} else {
currentToken = currentToken c
i++
}
}
}
if (currentToken)
returnTokens[p++] = currentToken
}
function parseJsonArray(returnAST, tokens,
leftBrackets,
rightBrackets,
separators,
i, j, key, p, stack, token) {
if (!leftBrackets[0]) {
leftBrackets[0] = "("
leftBrackets[1] = "["
leftBrackets[2] = "{"
}
if (!rightBrackets[0]) {
rightBrackets[0] = ")"
rightBrackets[1] = "]"
rightBrackets[2] = "}"
}
if (!separators[0]) {
separators[0] = ","
}
stack[p = 0] = 0
for (i = 0; i < length(tokens); i++) {
token = tokens[i]
if (belongsTo(token, leftBrackets))
stack[++p] = 0
else if (belongsTo(token, rightBrackets))
--p
else if (belongsTo(token, separators))
stack[p]++
else {
key = stack[0]
for (j = 1; j <= p; j++)
key = key SUBSEP stack[j]
returnAST[key] = token
}
}
}

function genRL(a, x,
b, c, d, i, y) {
tokenize(y, x)
parseList(b, y)
i = SUBSEP 0
print ("c: "c) > "/dev/stderr"
for (c = 0; c < length(b[i]) - 2; c += 3) {
d = b[i][c + 2]
print ("b[i][c + 2]: "b[i][c + 2]) > "/dev/stderr"
print ("i: "i) > "/dev/stderr";print ("c: "c) > "/dev/stderr"
print ("d  №1: "d) > "/dev/stderr"
d = d >= 97 ? d - 87 :
d - 48
print ("d №2: "d) > "/dev/stderr"
d = b[i][c + 1] == 43 ? rshift(a, d) : lshift(a, d)
print ("a №2: "a) > "/dev/stderr"
a = b[i][c] == 43 ? and(a + d, 4294967295) : xor(a, d)
print ("a №3: "a) > "/dev/stderr"
}
return a
}

function parameterize(string, quotationMark) {
if (!quotationMark)
quotationMark = "'"
if (quotationMark == "'") {
gsub(/'/, "'\\''", string)
return "'" string "'"
} else {
return "\"" escape(string) "\""
}
}

function dump(text, group,    command, temp) {
print ("start function dump ") > "/dev/stderr"
print ("text: -"text"-") > "/dev/stderr"
command = "hexdump" " -v -e'1/1 \"%03u\" \" \"'"
print ("command: "command) > "/dev/stderr"
("echo " parameterize(text) PIPE command) | getline temp
split(temp, group, " ")
print ("length(group)-1: "length(group) - 1) > "/dev/stderr"
return length(group) - 1
}

function genTK(text,
a, d, dLen, e, tkk, ub, vb) {
if (TK[text]) return TK[text]
tkk = systime() / 3600
print ("tkk: "tkk) > "/dev/stderr"
ub = "[43,45,51,94,43,98,43,45,102]"
print ("ub: "ub) > "/dev/stderr"
vb = "[43,45,97,94,43,54]"
print ("vb: "vb) > "/dev/stderr"
dLen = dump(text, d)
print ("dLen: "dLen) > "/dev/stderr"
a = tkk
print ("e: "e) > "/dev/stderr"
for (e = 1; e <= dLen; e++)
{a = genRL(a + d[e], vb);print ("e: "e) > "/dev/stderr";print ("a №1: "a) > "/dev/stderr"}
print (".....") > "/dev/stderr"
a = genRL(a, ub)
0 > a && (a = and(a, 2147483647) + 2147483648)
print ("a №2: "a) > "/dev/stderr"
print ("e: "e) > "/dev/stderr" 
a %= 1e6
print ("a №4: "a) > "/dev/stderr"
print ("-----------") > "/dev/stderr"
print ("a: "a " tkk: "tkk " xor(a, tkk): " xor(a, tkk) ) > "/dev/stderr"
TK[text] = a "." xor(a, tkk)
l(text, "text")
l(tkk, "tkk")
l(TK[text], "tk")
print ("text:--"text"--") > "/dev/stderr"
print ("TK[text]: "TK[text]) > "/dev/stderr"
return TK[text]
}


BEGIN {
initConst()
text = ARGV[2]
genTK(text)
print ("text: "text) > "/dev/stderr"
print ("TK[text]: "TK[text]) > "/dev/stderr"
print TK[text]
}
EOF

tk=`(gawk -f <(echo -E "$VAR_READ") - "$@" 2>/dev/null)` #Для того что бы не выводить отл.информац.
fun_debug "+DEBUG: Конец функции " "$FUNCNAME"
}


[ "$#" = "0" ] && fun_help && exit 0
fun_debug "+DEBUG: Разбор ключей."
#Разбор ключей.
while getopts ":t:in:d:hcp" Opt
do
check_arg_getopts
 case $Opt in
  t ) fun_trans_google "$OPTARG" || exit 1;;
  i ) fun_trans_loop;exit 0;;
  n ) fun_notification "$OPTARG" && break || exit 1;;
  d ) shift; fun_dictionary "$@" && break || exit 1;;
  h ) fun_help && exit 0;;
  c ) fun_check_file_dir;fun_check_package;;
  p ) fun_print_dict;;
  * ) echo -e "Не определены ключи.\n`(basename $0)` -h" && exit 1;;
 esac
done

rm $tmpfile
fun_debug "+DEBUG: Конец скрипта." "$FUNCNAME"

