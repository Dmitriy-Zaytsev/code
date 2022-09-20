#!/bin/bash
exec 2>/dev/null


packages='
ipcalc
snmp
snmp-mibs-downloader
'
for pack in $packages
 do
  dpkg-query -s $pack &>/dev/null || { echo "Не установлен пакет $pack" && exit 3;}
 done

snmp_community='kp2x45dv8v
ghbitktw'

net=$1
community=${2:-$snmp_community}


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
         exec 4>&1
         exec 1>&2
	 echo ++++++++++++++++++++++
        # ping -c 1 -W 1 $ip &>/dev/null || { echo "$ip не доступен.";continue;}
        # nmap -p 23 $ip | grep open &>/dev/null || { echo "$ip не доступен по telnet(23 port).";continue;}
        # nmap -sU -p 161 $ip | grep open &>/dev/null || { echo "$ip не доступен по snmp(161 port).";continue;}
#Раскоментировать если выполнять не от zabbix юзера.
#        check="`(sudo -u zabbix psql zabbix -U zabbix -h /var/run/postgresql -p 5432 -c "COPY (SELECT * FROM hosts WHERE host="\'$ip\'") TO STDOUT")`"
	check="`(psql zabbix -U zabbix -h /var/run/postgresql -p 5432 -c "COPY (SELECT * FROM hosts WHERE host="\'$ip\'") TO STDOUT")`"
#	[ -z "$check" ] && { echo "$ip нет в базе.";continue;}
         echo $ip
         for SNMP_COMMUNITY  in `(echo "$community" | sed 's/ /\n/g')`
           do
              model=`(snmpget -c $SNMP_COMMUNITY -v 1 -r 1 -t 2 -Oqv $ip .1.3.6.1.2.1.1.1.0 2>/dev/null)` #&& break
	      [ -n "$model" ] && break
           done
	    MODEL=$model
            [[ "$model" =~ "ME360x" ]] && MODEL="Cisco_ME-3600X-24FS-M"
            [[ "$model" =~ "Catalyst 4500" ]] &&  MODEL="Cisco_WS-C4500X-16"
            [[ "$model" =~ "ES4626-SFP" ]] && MODEL="Edge-Core_ES4626-SFP"
	    [[ "$model" =~ "ES3528M" ]] && MODEL="Edge-Core_ES3528M"
            [[ "$model" =~ "ES3552M" ]] && MODEL="Edge-Core_ES3552M"
	    [[ "$model" =~ "C2950" ]] && MODEL="Cisco_WS-C2950T-24"
            [[ "$model" =~ "C3750" ]] && MODEL="Cisco_WS-C3750G-24T-S"
            [[ "$model" =~ "C2800NM" ]] && MODEL="Cisco_2821"
	    [[ "$model" =~ "C3845" ]] && MODEL="Cisco_3845"
            [[ "$model" =~ "ECS3510-28T" ]] && MODEL="Edge-Core_ECS3510-28T"
            [[ "$model" =~ "ECS3510-52T" ]] && MODEL="Edge-Core_ECS3510-52T"
            [[ "$model" =~ "c7600" ]] && MODEL="Cisco_7606s"
            [[ "$model" =~ "Redback" ]] && MODEL="Ericsson_RedBack"
	    [[ "$model" =~ "Realtek-Switch" ]] && MODEL="DLink_DGS1100-08"
	    [[ "$model" =~ "ES3510MA" ]] && MODEL="Edge-Core_ES3510MA"
	    [[ "$model" =~ "C2960" ]] && MODEL="Cisco_WS-C2960G-24TC-L"
	    [[ "$model" =~ "UPS SNMP Agent" ]] && MODEL="Delta_GES102R"
	    [[ "$model" =~ "Linux GSE200M" ]] && MODEL="Huawei_1K"
	    [[ "$model" =~ "Lambda PRO 72" ]] && MODEL="Vector_Lambda-PRO-72"
	    [[ "$model" =~ "sdo3002" ]] && MODEL="Planar_SDO3002"
	    [[ "$model" =~ "tuz19-2003" ]] && MODEL="Planar_TUZ19-2003"
	    [[ -z "$MODEL" ]] && exit 1
           exec 1>&4
	   exec 4>&1
           echo $MODEL
       done
     done
   done
 done
}

ip_net
