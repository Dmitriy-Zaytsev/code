#!/bin/bash
#NetScan.sh -n /var/local/IP_acsw_chelny_dgs.txt
#psql -A -F ';' -t -P pager=off -h /var/run/postgresql/ -U net netdb -c "SELECT ip FROM scan WHERE model LIKE '%DGS-1100%' and date='2017-01-13' and snmp='1' and icmp='1';" | sudo -u dima xargs -i /usr/script_net/Get_port_dgs.sh {} | tee /tmp/dgs_port.csv 
IP=$1
OID_TIME=".1.3.6.1.2.1.1.3.0"
OID_SYSDESCR=".1.3.6.1.2.1.1.1.0"
OID_IFHCOUTOCT=".1.3.6.1.2.1.31.1.1.1.10"
#Uptime в секундах которое удв.условие.
UPTIME_GOOD="259200000"
COMMUNITY="ghbitktw"
SYSDESCR=`(snmpget -t 1 -r 0 -v 2c -c $COMMUNITY $IP $OID_SYSDESCR -Ovq 2>/dev/null)`
unset NAME ERROR TRUST NUMBER_PORT_FREE PORT_FREE
#IP;NAME;ERROR;TRUST;NUMBER_PORT_FREE;PORT_FREE
debug=0
[ "$2" = "-d" ] && debug=1
fun_debug () {
[ "$debug" = "1" ] || return 0
MESSAGE=$1
echo -e "$MESSAGE"
return 0
}

fun_out_csv () {
echo "$IP;$NAME;$ERROR;$TRUST;$NUMBER_PORT_FREE;$PORT_FREE"
}

fun_debug "-------------------"
if ping $IP -l 3 -c 2 -W 4 -D -n &>/dev/null
   then
	:
   else
	ERROR="PING"
	fun_debug "IP:$IP Не отвечает на ICMP."
	fun_out_csv
	exit 40
fi

if [ -z "$SYSDESCR" ]
   then
	ERROR="SNMP"
        fun_debug "IP:$IP Не отвечает на SNMP."
	fun_out_csv
	exit 60
fi
ERROR="GOOD"

NAME=`(get_ip_mysql.sh -i "$IP" | sed 's/\t/ /g' | cut -f 2 -d " ")`
#Получаем время uptime в секундах.
UPTIME=`(snmpget -t 1 -r 0 -v 2c -c $COMMUNITY $IP $OID_TIME -Ovt 2>/dev/null)`
fun_debug "IP:$IP NAME:$NAME"
fun_debug "\tUPTIME:"$UPTIME" > UPTIME_GOOD:"$UPTIME_GOOD""
if [[ "$UPTIME" -ge "$UPTIME_GOOD" ]]
   then
	fun_debug "\tВремя uptime подходит."
	TRUST="YES"
   else
	fun_debug "\tВремя uptime меньше положенного."
	TRUST="NO"
fi

IFOUTOCT=`(snmpwalk -t 1 -r 0 -v 2c -c $COMMUNITY $IP $OID_IFHCOUTOCT -On 2>/dev/null)`
NUMBER_PORT_FREE=`(echo "$IFOUTOCT" | grep  ": 0$" | wc -l)`
fun_debug "\tNUMBER_PORT_FREE:$NUMBER_PORT_FREE"
OLDIFS="$IFS"
IFS=$'\n'

for string in `(echo "$IFOUTOCT")`
    do
	echo "$string" | grep  ": 0$" &>/dev/null || continue
	PORT_FREE=${PORT_FREE:+$PORT_FREE,`(echo "$string" | sed 's/.*10.\(.*\) = .*/\1/g')`}
	PORT_FREE=${PORT_FREE:-`(echo "$string" | sed 's/.*10.\(.*\) = .*/\1/g')`}

    done
fun_debug "\tPORT_FREE:$PORT_FREE"
fun_out_csv
exit 0
