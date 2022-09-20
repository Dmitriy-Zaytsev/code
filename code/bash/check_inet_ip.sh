#!/bin/bash
[ ! "$UID" = "0" ] && { echo "Нет привелегий.";exit 1;}
user="speedtest"
password="d5vBY4gBAaEs"
interface="ppp87"
i=0
max_i=10

trap fun_ctrl_c INT

fun_ctrl_c () {
echo "Остановка PPPoE..."
poff -a
exit 0
}

fun_change_ip () {
echo "IP сменился: $ip_inet --> $ip_new `(date)`"
notify-send -t 0 "СМЕНИЛСЯ IP"
ip_inet=$ip_new
}

pon pppoe-mts user $user password $password
while ! ip link show $interface &>/dev/null
 do
   sleep 0.5
  ((i=$i+1))
  [ "$i" = "$max_i" ] && { poff -a;echo "Не удалось поднять PPPoE.";exit 1;}
 done
echo "PPPoE установлено."
date
ip add show ppp87 2>&1 | grep inet | sed 's/.*inet \(.*\) scope.*/\1/g'
ip_inet=`(curl www.check-host.net/ip 2>/dev/null)`
echo "Внешний ip: $ip_inet"

while true
 do
  ip_new=`(curl www.check-host.net/ip 2>/dev/null)`
  [ ! "$ip_inet" = "$ip_new" ] && fun_change_ip
  sleep 2
 done
