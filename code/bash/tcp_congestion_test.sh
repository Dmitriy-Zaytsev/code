#!/bin/bash
TPUT=/usr/bin/tput
GREEN=$($TPUT setaf 2)
NORMAL=$($TPUT op)
max_test=3
file=https://cdimage.debian.org/debian-cd/current/s390x/iso-cd/debian-9.2.1-s390x-netinst.iso


sysctl -a >/tmp/sysctl.conf.current
exec 3>&1
exec 1>/dev/null
sysctl net.core.rmem_max=16777216
sysctl net.core.wmem_max=16777216
sysctl net.core.rmem_default=16777216
sysctl net.core.wmem_default=16777216
sysctl net.core.optmem_max=40960
sysctl net.ipv4.tcp_rmem="4096 87380 16777216"
sysctl net.ipv4.tcp_wmem="4096 65536 16777216"
sysctl net.ipv4.tcp_sack=1
exec 1>&3

for algoritm in `(cat /proc/sys/net/ipv4/tcp_available_congestion_control | sed 's/ /\n/g')`
 do
  echo -e "TCP CONGESTION ALGORITM: ${GREEN}$algoritm${NORMAL}"
  echo $algoritm > /proc/sys/net/ipv4/tcp_congestion_control
  for test in `(seq 1 "$max_test")`
   do
    echo "TEST $test: `(wget $file  --report-speed=bits -O - 2>&1 >/dev/null | grep -E -v "^ *$" | tail -n 1 | sed 's/.*(\(.*\)).*/\1/g')`"
   done
 done




##Возвращаем настройки по умолчанию
#sysctl -p /tmp/sysctl.conf.current
rm /tmp/sysctl.conf.current -f
