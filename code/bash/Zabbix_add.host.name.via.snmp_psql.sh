#!/bin/bash
packages='
ipcalc
snmp
snmp-mibs-downloader
'
for pack in $packages
 do
  dpkg-query -s $pack &>/dev/null || { echo "Не установлен пакет $pack" && exit 3;}
 done

snmp_community='
kp2x45dv8v
ghbitktw
'

net=$1



ip_net () {
ipcalc $net | grep -i invalid &>/dev/null && { echo "Не некорректный IP адрес $net." && exit 1;}
host_min=`(ipcalc -n -b $net | grep -i hostmin | sed -E "s/ {1,99}/ /g" | cut -d  " "  -f 2)`
host_max=`(ipcalc -n -b $net | grep -i hostmax | sed -E "s/ {1,99}/ /g" | cut -d  " "  -f 2)`
[ "$host_min" == "" -a "$host_max" == "" ] && \
{ host_min=`(ipcalc -n -b $net | grep -i address | sed -E "s/ {1,99}/ /g" | cut -d  " "  -f 2)` &&\
 host_max=$host_min;}
oct_min=`(echo $host_min | tr '.' '\n')`
oct_min=($oct_min)
oct_max=`(echo $host_max | tr '.' '\n')`
oct_max=($oct_max)
for oct1 in `seq ${oct_min[0]} ${oct_max[0]}`
 do
  for oct2 in `seq ${oct_min[1]} ${oct_max[1]}`
   do
    for oct3 in `seq ${oct_min[2]} ${oct_max[2]}`
     do
      for oct4 in `seq ${oct_min[3]} ${oct_max[3]}`
       do
         ip="$oct1.$oct2.$oct3.$oct4"
	 echo $ip
	 ping -c 1 -W 1 $ip &>/dev/null || { echo "$ip не доступен.";continue;}
         nmap -p 23 $ip | grep open || { echo "$ip не доступен по telnet(23 port).";continue;}
	 nmap -sU -p 161 $ip | grep open || { echo "$ip не доступен по snmp(161 port).";continue;}
	 [ -z "`(sudo -u zabbix psql zabbix -U zabbix -c "COPY (SELECT * FROM hosts WHERE host="\'$ip\'") TO STDOUT")`" ] && { echo "$ip нет в базе.";continue;}
         for community  in $snmp_community
	   do
              hostname=`(snmpget -c $community -v 2c -r 1 -t 2 -Oqv $ip .1.3.6.1.2.1.1.5.0  2>/dev/null)` && break
	   done
	sudo -u zabbix psql zabbix -U zabbix -c "UPDATE hosts SET name="\'$hostname\'" WHERE host="\'$ip\'";" | grep UPDATE &>/dev/null && echo "$ip $hostname UPDATE"
       done
     done
   done
 done
}

ip_net
