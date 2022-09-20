#!/bin/bash

#MODEL:Lambda PRO 72 FIRMWARE:1.3.0
#MODEL:Lambda PRO 72 FIRMWARE:1.4.0
#MODEL:Lambda PRO 72 FIRMWARE:1.4.5
#MODEL:sdo3001 FIRMWARE:12.9.2
#MODEL:sdo3002 FIRMWARE:12.9.1

#Выяснение на каком порту находиться оптический тв усилитель.

[ ! "$UID" = "0" ] && { echo "Нет прав." ;exit 1;}
fun_help () {
echo "
Сканирование mac-ов ТВ усилителей с последующим поиском на коммутаторах.
`(basename $0)` -n {ipaddress_tv/cidr[,ipaddress_tv/cidr]|file_tv} -N {ipaddress_sw/cidr[,ipaddress_sw/cidr]|file_sw}
"
exit 0
}


snmpcomm="ghbitktw"
snmpcomm_tv=${snmpcomm:-private}
snmpcomm_sw=${snmpcomm:-private}
file_tv_ipmac=/var/local/file_tv_ipmac.txt
file_out=/var/local/file_out.txt
file_tmp=/tmp/file.tmp
vlan=108

packages='
snmp
nmap
ipcalc
lsof
bc
'
for pack in $packages
 do
  dpkg-query -s $pack &>/dev/null || { echo "Не установлен пакет $pack" && exit 3;}
 done

fun_iprange () {
[ -f $1 ] && { cat $1;return 0;}
OLDIFS=$IFS
IFS=','
for net in $1
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

fun_checkavailable () {
ip=$1
ping $ip -l 5 -c 2 -W 1 -D -n &>/dev/null || { echo "$ip --> Недоступен ICMP.";return 1;}
nmap -sU -n -p 161 $ip | grep -i '161/udp open' &>/dev/null  || { echo "$ip --> Недоступен SNMP.";return 1;}
echo $ip
}

fun_parsmac () {
STDIN=${1:-$(</dev/stdin)}
echo $STDIN |  sed -E 's/:|"|-|\.|\ //g' | tr '[:upper:]' '[:lower:]' |  sed -E "s/([a-f,0-9]{2})/&:/g" | sed 's/:$//g'
}


fun_tvmac () {
ip=$1
fun_checkavailable $ip || return 1
model=`(snmpget -v 1 -c $snmpcomm_tv -t 1 -r 0 -Oqvn $ip sysDescr.0 2>/dev/null)`
[ -z "$model" ] && return 0
sysObject_oid=`(snmpget -v 1 -c $snmpcomm_tv -t 1 -r 0 $ip .1.3.6.1.2.1.1.2.0 -Onqv 2>/dev/null)`
for ind in 1 5
 do
  firm_oid=""$sysObject_oid"."$ind".2.0 -Oqvna"
  firm=`(snmpget -v 1 -c $snmpcomm_tv -t 1 -r 0 $ip $firm_oid 2>/dev/null | tr -d '"' | sed 's/\.$//g')`
  [ ! -z "$firm" ] && break
done

firm=${firm:-???}
unset mac_oid
case $model in
	"Lambda PRO 72" )
            case $firm in
		"1.3.0" ) mac_oid=".1.3.6.1.4.1.5591.1.3.2.7.0 -Oqvn";;
		"1.4.0" ) mac_oid=".1.3.6.1.4.1.5591.1.3.2.7.0 -Oqvn";;
	 	"1.4.5" ) mac_oid=".1.3.6.1.4.1.5591.1.3.2.7.0 -Oqvn";;
	    esac
	;;
	"sdo3001" )
	    case $firm in
                "12.9.2" ) mac_oid=".1.3.6.1.4.1.32108.1.8.1.4.0 -Oqvna";;
            esac
	;;
	"sdo3002" )
	    case $firm in
                "12.9.1" ) mac_oid=".1.3.6.1.4.1.32108.1.7.1.4.0 -Oqvna";;
            esac
	;;
esac
[ -z "$mac_oid" ] && echo "Нет oid для получения mac адреса TV $ip."
tv_mac=`(snmpget -v 1 -c $snmpcomm_tv -t 1 -r 0 $ip $mac_oid 2>/dev/null | fun_parsmac )`
tv_mac=${tv_mac:-???}
echo ${model:+IP:$ip MODEL:$model FIRMWARE:$firm MAC:$tv_mac}
while true
 do
  lsof &>/dev/null $file_tv_ipmac || break
  sleep 1
 done
echo ${tv_mac:+$ip;$tv_mac} >> $file_tv_ipmac
}

fun_scantv () {
echo "+++++Получение mac-ов ТВ усилителей+++++"
i=0
for ip in $(fun_iprange "$net_tv")
do
 ((i=i+1))
 fun_tvmac $ip &
 (($i%25)) || wait
done
wait
cat $file_tv_ipmac | sort -h -k1 | uniq > $file_tmp
cp -rf $file_tmp $file_tv_ipmac
rm -rf $file_tmp
}

fun_swmac () {
ip=$1
fun_checkavailable $ip || return 1
mac_port=`(snmpwalk -c $snmpcomm_sw -v 2c $ip .1.3.6.1.2.1.17.7.1.2.2.1.2.$vlan -On 2>/dev/null)`
echo $mac_port | grep "No Such" && unset mac_port
[ -z "$mac_port" ] && { echo "Нет Vlan:$vlan на SW:$ip.";return 0;}
OLDIFS=$IFS
IFS=$'\n'
for line_macport in `(echo "$mac_port")`
  do
    MAC=`(echo "$line_macport" | sed "s/.*2."$vlan".\(.*\) = INTEGER: \(.*\)/\1/g")`
    PORT=`(echo "$line_macport" | sed "s/.*2."$vlan".\(.*\) = INTEGER: \(.*\)/\2/g")`
    #port 1 vlan = access.
    [ `(snmpwalk -c $snmpcomm_sw -v 2c $ip .1.3.6.1.2.1.17.7.1.2.2.1.2 2>/dev/null | grep "INTEGER: $PORT" | wc -l)` = "1" ] || continue
    IFS='.'
    unset temp_mac
    for mac_dec in $MAC
      do
        temp_mac=""$temp_mac"`(echo "ibase=10;obase=16;$mac_dec" | bc | sed 's/^.$/0&/g')`"
      done
    IFS=$OLDIFS
    MAC=`(echo "$temp_mac" | fun_parsmac )`
    echo "IP:$ip MAC:$MAC PORT:$PORT"
    iptv=`(grep ";"$MAC"$" $file_tv_ipmac | cut -f 1 -d ";")`
    if [ ! -z "$iptv" ]
          then
            echo "На коммутатор $ip подключен $iptv в port $PORT."
           while true
            do
              lsof &>/dev/null $file_out || break
              sleep 1
            done
            echo "$ip|$PORT|$iptv|1" >> $file_out
        fi
  done

}

fun_find () {
echo "+++++Поиск по коммутаторам ТВ усилителей+++++"
[ -r "$file_tv_ipmac" ] || { echo "Нет прав на чтение или нет файла "$file_tv_ipmac".";exit 1;}
[ -s "$file_tv_ipmac" ] || { echo "Нет данных в "$file_tv_ipmac".";exit 1;}
i=0
for ip in $(fun_iprange "$net_sw")
do
 ((i=i+1))
 fun_swmac $ip &
 (($i%25)) || wait
done
wait
cat $file_out | sort -h -k1 | uniq > $file_tmp
cp -rf $file_tmp $file_out
rm -rf $file_tmp
}


while getopts "hn:N:" Opts
  do
     case $Opts in
        n) net_tv=$OPTARG;fun_scantv;;
	N) net_sw=$OPTARG;fun_find;;
	h) fun_help;;
     esac
  done
