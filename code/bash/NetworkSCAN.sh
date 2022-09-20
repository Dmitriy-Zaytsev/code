#!/bin/bash
#Покажет ветку system.
#snmpwalk -c ghbitktw -v 2c 172.19.3.110 -On

mkdir -p ./NetworkSCAN/ &>/dev/null
rm ./NetworkSCAN/* -r &>/dev/null
#Откл курсор.
tput civis
fun  ()
{
ip=172.19.$oct3.$oct4
#Жёлт.
tput setaf 3
#Вывод не спускаясь на следующию строку удаляя предидущее.
tput el
echo -en $ip
#Белый.
tput setaf 7
#Встаём курсором на позицию ноль
tput hpa 0
model=`(snmpget -r 2 -t 1 -c ghbitktw -v 2c $ip .1.3.6.1.2.1.1.1.0 2>/dev/null | sed 's/.*://g' | sed -E 's/(\/| )//g')`
[ ! -z "$model" ] && \
{ hostname=`(snmpget -r 2 -t 1 -c ghbitktw -v 2c $ip .1.3.6.1.2.1.1.5.0 2>/dev/null | sed 's/.*STRING: \(.*\)/\1/g')` ; \
file="./NetworkSCAN/$model.txt"
echo $ip $hostname >> $file && return 0;}
return 1
}
#stdout сделам как stderr.
echo "START find model all." >&2
  for oct3 in `(seq 0 7)`
   do
    for oct4 in `(seq 0 255)`
     do
      #tput el - очищаем посл.строку.
      fun && tput el && tail -n 1 $file
     done
   done
 for oct3 in `(seq 64 69)`
   do
    for oct4 in `(seq 0 255)`
     do
      fun && tput el && tail -n 1 $file
     done
   done
#Вкл. курсор.
tput cnorm
echo "STOP find model all." >&2

