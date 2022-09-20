#!/bin/bash
#Покажет время от первого не полученного replay, до первого полученного.
ip="${1:-192.168.33.1}" #Если нет или не пустая $1 тогда примет значение 192.168.33.1
date_no_ping=; #Дата когда не пришёл ответ.
date_yes_ping=; #Дата перврго ответа после того как не было ответа.
repaly="no";
echo "ping $ip"
date_start=`(date "+%d/%m/%y %H:%M:%S:%N")`
while true
 do
  if ping $ip -c 1 -w 1 | grep from &>/dev/null
    then #replay пришёл.
         replay="yes" #Т.е. ответ мы уже хоть раз получили.
         echo -en "."
         if [ -n "$date_no_ping" ] #Если пинга хоть раз не было(переменная не пустая). 
           then
             date_yes_ping=`(date "+%d/%m/%y %H:%M:%S:%N")`
             echo -e "\n$date_yes_ping - ping $ip yes replay"
             echo "$date_start - ping $ip start date"
             exit
         fi
    elif [ -z "$date_no_ping" ] && [ "$replay" = "yes" ] #replay НЕпришёл.
         then
                 date_no_ping=`(date "+%d/%m/%y %H:%M:%S:%N")`
                 /usr/bin/beep -l 5000 -f 900
                 echo -e "\n$date_no_ping - ping $ip no replay"
  fi
 done
