#!/bin/bash
#Заxодим на сайт teztour-chelny.ru/poisk-tura/ вбиваем данные
#данные формируются с module.sletat.ru, точней в начале формируеться временная ссылка с кодом, а патом
#мы на неё заходим.
#Ключь -s покажет что получили но не будет сравнивать с предидущим файлом.
http_get_code='http://module.sletat.ru/Main.svc/QueueActualization?requestId=1292931508&offerId=1764491052&sourceId=635262944&detailed=1&command=Init&countryId=40&townFromId=1289&showcase=0&commandArguments=&actualizationSessionId=&currencyAlias=RUB&callback=sletat.Service.callback(%22m4-22%22)&debug=0&target=module-4.0&t=1437605134746'
date=`(date "+%d/%m/%y %H:%M")`
script=`(basename $0)`
fileTMP="/tmp/"$script".tmp"
fileNEW="$HOME/"$script"_New.txt"
fileOLD="$HOME/"$script"_Old.txt"
fileFIND="$HOME/"$script"_Find.txt"
fileLOG="$HOME/"$script".log"
fileMAIL="$HOME/"$script"_Mail.txt"
mail_to='shnufik18.07.87@gmail.com,stasja93.93@mail.ru'
#mail_to='shnufik18.07.87@gmail.com'

#colRED="\e[1;31m"
#colGREN="\e[0;32m"
#colEND="\e[0m"
#colYELLOW="\e[0;33m"

fun_error () {
message="$1"
echo "<"$script">[ERROR]"$date"--->"$message"" | tee -a "$fileLOG"
exit 2
}

fun_success () {
message="$1"
echo -e "`(echo "<"$script">[OK]"$date"--->"$message"" | sed 's/\\n/\n/g' )`" | tee -a "$fileLOG"
[ "$2" = "SEND_MAIL" ] && { fun_send_mail "$message" && return 0 || return 1;}
return 0
}

fun_send_mail () {
echo -e "`(echo "$message" | sed 's/\\n/\n/g' )`" > "$fileMAIL"
sed "1 s/^/To\:\nFrom\:shnufik18.07.87@gmail.com\nSubject\:Путёвки\nContent-Type: text\/plain; charset=UTF-8; format=flowed\n\n/g" -i "$fileMAIL"
/usr/sbin/ssmtp "$mail_to" < "$fileMAIL" -v || return 1
return 0
}


for file in "$fileOLD" "$fileNEW" "$fileTMP" "$fileLOG" "$fileMAIL"
do
[ ! -f $file ] && > $file
[ ! -r $file ] && fun_error "$file не доступен на чтение."
[ ! -w $file ] && fun_error "$file не доступен на запись."
done


rm $fileTMP
rm $fileNEW



fun_curl () {
code=`(curl -L -X GET -A "User-Agent: Mozilla/5.0 (X11; Linux i686; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.3.0" \
--header "Accept-Language: en-US,en;q=0.5" \
--header "Referer: http://teztour-chelny.ru/poisk-tura/" \
"$http_get_code" \
-v 2>/dev/null | grep -i code | sed 's/.*Code\"\:\"\(.*\)==.*/\1/g' )`
echo "oldcode -> $code"
#Заменим в полученном коде \/ на %2f (url допустимые символы).Возможно есть ещё не допустимые символы.
code=$(echo "$code" | sed 's/\\\//%2f/g')

#echo $code
http='http://module.sletat.ru/Main.svc/GetActualizationResult?code='$code'%3D%3D&callback=sletat.Service.callback(%22m4-12%22)&debug=0&target=module-4.0'

#Ждём пока  предидущий запрос сформирует ссылку, для следужего get запроса.
sleep 1

curl -L -X GET -A "User-Agent: Mozilla/5.0 (X11; Linux i686; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.3.0" \
--header "Accept-Language: en-US,en;q=0.5" \
--header "Referer: http://teztour-chelny.ru/poisk-tura/" \
"$http" \
-v 2>/dev/null > "$fileTMP"
echo "http_get_code -> $http_get_code"
echo "code -> $code"
echo "http -> $http"
}


fun_curl

num=0
word=`( wc -w "$fileTMP" | cut -f 1 -d " ")`
while [ "$word" -le "20" ]
 do
  ((num=num+1))
  word=`( wc -w "$fileTMP" | cut -f 1 -d " ")`
  sleep 1
  echo -e "\n"$colRED"RESTART"$colEND"\n"
  fun_curl
  [ "$num" = "4" ] && fun_error "Слишком много попыток взять данные с сайта."
 done

[ "`(wc -l $fileOLD | cut -f 1 -d " ")`" = "1" ] && rm $fileOLD

echo "$date" > "$fileNEW"
cat "$fileTMP" | grep --color '\[\|\]' | \
sed 's/\[/\n/g'| sed 's/\]/\n/g' | \
sed -n '2p' | sed 's/,//g' | sed 's/""*/"/g' | sed 's/^\"//g' | \
sed 's/\"/;/g' | \
awk -F ";" '{print ""$5"-"$11";"$2"-->"$3"("$1");"$7"("$9")-"$39";"$37";"$20" RUB"}' | \
awk '! a[$0]++'  >> "$fileNEW"

[ "$1" = "-s" ] && cat "$fileNEW" && fun_success

#Допустим если мы в первый раз запустили скрипт и прошлых данных нет.
[ ! -s  $fileOLD ] && cp $fileNEW $fileOLD -f

while read stringNEW
 do
  echo $stringNEW $stringOLD
  [ "$stringNEW" = "$date" ] && continue
  dateN=`(echo $stringNEW | cut -d ";" -f 1)`
  placeN=`(echo $stringNEW | cut -d ";" -f 2)`
  hotelN=`(echo $stringNEW | cut -d ";" -f 3)`
  costN=`(echo $stringNEW | cut -d ";" -f 5 | sed 's/ RUB//g')`
  hotelN_grep=`(echo "$hotelN" | sed 's/\*/\\\*/g' | sed 's/(/\\\(/g' | sed 's/)/\\\)/g' | sed 's/\ /\\\ /g' | sed 's/\[/\\\[/g' | sed 's/\]/\\\]/g')`
  placeN_grep=`(echo "$placeN" | sed 's/\*/\\\*/g' | sed 's/(/\\\(/g' | sed 's/)/\\\)/g' | sed 's/\ /\\\ /g' | sed 's/\[/\\\[/g' | sed 's/\]/\\\]/g')`
  echo "FIND << "$dateN" "$placeN_find" "$hotelN_find" >>"
  stringOLD=`( ! grep "$dateN" "$fileOLD" | grep  -E  "$placeN_grep" | grep -E "$hotelN_grep")` && echo -e "\e[0;31mВ файле $fileOLD не найдено $stringNEW\e[0m"
  if [ ! -z "$stringOLD" ]
   then
    costO=`(echo $stringOLD | cut -d ";" -f 5 | sed 's/ RUB//g')`
    if [ ! "$costN" = "$costO" ]
     then
      date_scanN=`(sed -n '1p' $fileNEW)`
      date_scanO=`(sed -n '1p' $fileOLD)`
      fun_success ""$colGREN"Стоимость путёвки изменилась."$colEND"\n$dateN $placeN $hotelN\n$date_scanO($costO RUB)-->$date_scanN($costN RUB)\n" "SEND_MAIL" || fun_error "Неудачная отправка почты."
     else
      fun_success ""$colYELLOW"Стоимость путёвки не изменилась."$colEND"\n$dateN $placeN $hotelN $costN RUB\n"
    fi
   else
    fun_error ""$colRED"Ни одно соответствие не найдено."$colEND""
  fi
  done < $fileNEW

cp $fileNEW $fileOLD -f
exit 0
