#!/bin/bash
#Нужно запускать как демон (можно добавить задержку для того что бы постоянно не проверял top процессов) с приоритетом (nice -n 20),
#или по cron-у но для cron-а может не хватить mem/cpu для запуска когда система виснет.
max_cpu=35
max_mem=30
max_nice=0 #Процессы у которых приоритет будет больше (меньше) не будут расматриваться для kill-а.
syslog="local6.alert" #facility.priority для оповещения при kill-е для rsyslog.


while read string
do
echo $string
#sleep 1
pid=`(echo $string | cut -d " " -f 1)`
cpu=`(echo $string | cut -d " " -f 9)`
mem=`(echo $string | cut -d " " -f 10)`
nice=`(echo $string | cut -d " " -f 4)`
command=`(echo $string | cut -d " " -f 12)`

echo "PID: "$pid""
echo "CPU: "$cpu""
echo "MEM: "$mem""
echo "NICE: "$nice""
echo "COMMAND: "$command""
#sleep 1
if [[ "$nice" -le "$max_nice" ]]
 then
#==> stress -c 4 #Проверка.
#${max_cpu/,/.} передаём bc число с заменой на точку, если выполниться то bc отдаст на вывод 0.
#Используем bc так как с помощью [[ ]] числа с плавающей запятой не верно сравниваются.
  if [[ $(echo "if ("${cpu/,/.}">="${max_cpu/,/.}") 0" | bc -s) = "0" ]]
   then
    echo "MAX CPU PROCESS: KILL PID: $pid COMMAND:$command"
    kill -9 "$pid"
    logger "MAX CPU PROCESS: KILL PID:$pid COMMAND:$command"  -t "`(basename $0)`" -p "$syslog"
    wall  "`(basename $0)` MAX CPU PROCESS: KILL PID:$pid COMMAND:$command"
  fi
#==> stress -m 1 --vm-bytes 4096M -t 10s #Проверка.
  if [[ $(echo "if ("${mem/,/.}">="${max_mem/,/.}") 0" | bc -s) = "0" ]]
   then
    #echo "MAX MEM PROCESS: KILL PID: $pid"
    kill -9 "$pid"
    logger "MAX MEM PROCESS: KILL PID:$pid COMMAND:$command COMMAND:$command"  -t "`(basename $0)`" -p "$syslog"
    wall  "`(basename $0)` MAX MEM PROCESS: KILL PID:$pid COMMAND:$command"
  fi
fi

done < <(top -b -n1 -i | sed -n '/PID/,/.*/p' | grep -v PID | sed -E -e 's/ {1,9}/ /g' -e 's/\^ //g')
