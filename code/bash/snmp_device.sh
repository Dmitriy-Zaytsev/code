#!/bin/bash
#Скан сети или определённого ip (script.sh 0.64)и выяснение device,hostname, можем также указать 2-а последних октета через точку как аргумент.
#Есть проблема dlink-dgs-1100-08 не верную инф. передают по snmp v2, поэтому запускаем expect.
#Для отображения MAC сканируемые адреса должны быть в одной подсети, но тогда
#EdgeCore может не ответить на snmp так как management snmp-client будет из другой подсети.
oct3=;
oct4=;
fun ()
{   #Если хоть один replay из одного (-с 1) прийдёт тогда результат выполнения 0(true).
    if  ping 172.19.$oct3.$oct4 -c 1 -W 1 -s 56 &>/dev/null
     then
      #r-повторов,t-таймаут, v-версия, с-community.
      device=`(snmpget -v 2c -c ghbitktw 172.19.$oct3.$oct4 .1.3.6.1.2.1.1.1.0 2 -r 2 -t 1  2>/dev/null | sed -E "s/^.*\:.//" | sed -E -n "1p")`
      hostname=`(snmpget -v 2c -c ghbitktw 172.19.$oct3.$oct4 .1.3.6.1.2.1.1.5.0 -r 2 -t 1 0 2>/dev/null | sed -E "s/^.*\:.//" | sed -E -n "1p")`
      if [ "$device" = "Realtek-Switch" ] && [ "$hostname" = "RTL8370M" ] #Значит dlink-1100-08 который нам инф по snmp не дал.
        then
#Запускаем expect с аргументом  IP.
            /usr/bin/expect `(dirname $0)`/snmp_device.exp 172.19.$oct3.$oct4 &>/dev/null || echo -en "\t     ..not connect telnet" #если expect не сможет зайти (вернёт 1), тогда echo.
            device=DGS-1100-08 #так как мы уверены что это dlink-1100-08.
            hostname=`(cat /tmp/hostname_dlink.tmp)` #результат полученный от expect.
            > /tmp/hostname_dlink.tmp #Чистим файл.
        fi
      mac=`(snmpget -v 2c -c ghbitktw 172.19.$oct3.$oct4 .1.3.6.1.2.1.2.2.1.6.1 -r 2 -t 1  2>/dev/null | cut -d " " -f 4)` || true
      [ -z  $mac ] &&  mac=0`( snmpget -v 2c -c ghbitktw 172.19.$oct3.$oct4 .1.3.6.1.2.1.2.2.1.6.604 -r 2 -t 1 | cut -d " " -f4)` || true #Если $mac пустой значит dlink2108 не передал инф о sysmac, тогда попросим у него другой mib, поставив к полученному пропущенный ноль, так как он выдаёт не полный mac.
      echo -e "\r172.19.$oct3.$oct4" #\r - в начало строки, нужно для того что бы  not connect telnet  был написан после IP.
      echo $device
      echo $hostname
      echo $mac
      echo ......
    fi
}
date "+%d/%m/%y %H:%M:%S:%N"
echo ...............START.....................
if [ -z $1 ] #Если не задан даже первый аргумент.
 then
  for oct3 in `(seq 64 73)`
   do
    for oct4 in `(seq 0 255)`
     do
      fun
     done
   done
  for oct3 in 10
   do
    for oct4 in `(seq 0 255)`
     do
      fun
     done
   done
  for oct3 in `(seq 0 7)`
   do
    for oct4 in `(seq 0 255)`
     do
      fun
     done
   done
 else #Если есть первый аргумент, тогда разберём его.
  oct3=`(echo $1| sed -E "s/\..*//g")`
  oct4=`(echo $1| sed -E "s/.*\.//g")`
  echo IP= 172.19.$oct3.$oct4
  fun
fi
echo ................END......................
date "+%d/%m/%y %H:%M:%S:%N"

