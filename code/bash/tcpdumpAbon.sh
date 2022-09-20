#!/bin/bash
##tcpdump -i eth0 -w ./dump.cap #Дамп надо запустить в другом терминале что бы можно было его остановить.
##Скрипт и tcpdump запускаем от su или sudo su.
##От скрипта мало пользы так как прочитать что то будет тяжело.
tail -f -s 1 ./dump.txt &
while true
 do
   if ps -ax | grep -w "tcpdump -i eth0 -w ./dump.cap" | grep -v grep
      then
          tcpdump -r ./dump.cap -nn > ./dump.txt 2>/dev/null
          sleep 1
     else echo -e "\n\n-------------Не запущен tcpdump.-------------\n\n"; break
   fi
 done
kill $! #Убить последний процесс запущенный в фоне.
wait #Ждём до тех пор пока не завершаться процессы порождённые данным скриптом.
exit
