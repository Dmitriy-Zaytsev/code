#!/bin/bash
[ "$UID" = "0" ] || { echo "Нужны права root." && exit 1;}
PSQL="psql -h /var/run/postgresql/ -U net netdb"

fun_checkpack () {
packages='
snmp
nmap
ipcalc
postgresql-9.5
postgresql-client-9.5
snmp-mibs-downloader
'
for pack in $packages
 do
  dpkg-query -s $pack &>/dev/null || { echo "Не установлен пакет $pack" && exit 3;}
 done
}



fun_psql () {
command="$1;"
param="${2:-}"
$PSQL $param -c "$command"
}

fun_iprange () {
[ -z "$1" ] && { echo "0.0.0.0/0" ;return 0;}
NET=$1
[ -f "$NET" ] && NET=`(grep -v "#" $NET | cut -f 1 -d ";" | sed '/\//! s/$/\/32/g' | tr '\n' ',')`
OLDIFS=$IFS
IFS=','
for net in $NET
 do
  IFS=$OLDIFS
  ipcalc_out=`(ipcalc $net -n -b)`
  echo "$ipcalc_out" | grep -i invalid &>/dev/null && { echo "Не некорректный IP адрес $net." && exit 1;}
  host_min=`(echo "$ipcalc_out" | grep -i hostmin | sed -E "s/ {1,99}/ /g" | cut -d  " "  -f 2)`
  host_max=`(echo "$ipcalc_out" | grep -i hostmax | sed -E "s/ {1,99}/ /g" | cut -d  " "  -f 2)`
  [ "$host_min" == "" -a "$host_max" == "" ] && \
  { host_min=`(echo "$ipcalc_out" | grep -i address | sed -E "s/ {1,99}/ /g" | cut -d  " "  -f 2)` &&\
  host_max=$host_min;}
  oct_min=`(echo $host_min | tr '.' '\n')`
  oct_min=($oct_min)
  oct_max=`(echo $host_max | tr '.' '\n')`
  oct_max=($oct_max)
  i=0
  for oct1 in `seq ${oct_min[0]} ${oct_max[0]}`
   do
    for oct2 in `seq ${oct_min[1]} ${oct_max[1]}`
     do
      for oct3 in `seq ${oct_min[2]} ${oct_max[2]}`
       do
        for oct4 in `seq ${oct_min[3]} ${oct_max[3]}`
         do
          ip=$oct1.$oct2.$oct3.$oct4
          echo $ip
         done
       done
     done
   done
 done
}


fun_access () {
icmp=0
snmp=0
telnet=0

ping $ip -l 3 -c 1 -W 1 -n &>/dev/null || return 1
icmp=1
nmap -sT -p T:23 -n $ip  | grep open &>/dev/null && telnet=1
nmap -sU -p U:161 -n $ip | grep open &>/dev/null && snmp=1
}

