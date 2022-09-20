#!/bin/bash
#ipaddress="$1"
ipaddress="192.168.33.0/24,172.21.64.0/24,172.19.32.0/24,172.19.33.0/24,172.19.34.0/24,172.19.130.219"
packages='
prips
'
for pack in $packages
do
dpkg-query -s $pack &>/dev/null || { echo "$pack не установлен."; exit 1;}
done

for ipcidr in `(echo $ipaddress | sed 's/,/\n/g')`
  do
	for ip in `(prips $ipcidr)`
		do
			echo -en "$ip"
			if ! ping $ip -c 1 -W 1 -l 2 &>/dev/null
				then
					echo -e " - Error ping.\n";continue
				else
			nmap $ip -p 23 | grep -i "23/tcp open" &>/dev/null || { echo -e " - Error telnet.\n";continue;}
			echo -e " - Run configure device.\n"
			/usr/zabbix/Configure_for-snmp-server.exp $ip
			fi
		echo -e "\n"
		done
  done
