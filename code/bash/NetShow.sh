#!/bin/bash
WORKDIR="/usr/script_net"
. $WORKDIR/NetFUNCTION.sh

fun_help () {
script=`(basename $0)`
echo "
-S -таблица информации о моделях устройств.
	-m  -модель.
	-n  -network.
	-f  -firwmare.
	-t  -telnet{0|1}.
	-s  -snmp{0|1}.
	-c  -количество хостов {model {,firmw,|telnet,|snmp|-} }
		"-" -default model,firmw,telnet,snmp.
	-d  -date. По умолчанию текущая дата.

-C -таблица результат выполнения скриптов.
	-S  -результат выполнения {1|100} 100-выполненно. По умолчанию 1 -не выполненно.
	-s  -имя скрипта, - заменить на любой символ(%).
	-n  -network.
	-d  -date. По умолчанию текущая дата.

example:
$script -S -m %ES3510% -f 1.4.2.4 -n 172.19.0.0/21 -t 1 -s 1 #ES3510MA с прошивкой -f 1.4.2.4 из сети 172.19.0.0/21.
$script -S -c -m %DES% -t 1 #DES-ы c открытым telnet.
$script -S -c model,firmw #Только модель,прошивка, и количество повторов.
$script -S -c model,firmw,telnet -t 1 #Отсартируем и покажет у кого  открыт 23 порт.
$script -S -m %ES3510% -t  1 -n 172.19.0.13/32,172.19.0.21/24
$script -S -m %ECS3510%28% #!!!! Минус нужно заменить на любой знак(%).

$script -C -S 1  -s %tacacs% -n 172.19.0.3/32,172.19.0.212 -d 2016-10-27
SQL SELECT:
SELECT ip,date,success FROM conf WHERE success='1' AND date='2016-10-28' GROUP BY ip,date,success;
"
exit 0
}


fun_checkpack


fun_SCAN () {
OLDIFS=$IFS
IFS=','
for ip in $net
 do
  echo IP/NET: $ip
  IFS=$OLDIFS
  if [ "$count" = "1" ]
     then
       COLUMN_SORT=${COLUMN_SORT:-"model,firmw,telnet,snmp"}
       fun_psql "SELECT $COLUMN_SORT,COUNT(ip) FROM scan WHERE (model LIKE "\'$model\'" AND date="\'$date\'" AND firmw LIKE "\'$firmw\'" AND (ip<<"\'$ip\'" OR ip="\'$ip\'") \
       AND CAST(telnet AS TEXT) LIKE "\'$telnet\'" AND CAST(snmp AS TEXT) LIKE "\'$snmp\'") GROUP BY $COLUMN_SORT ORDER BY model;"
     else
       fun_psql "SELECT * FROM scan WHERE (model LIKE "\'$model\'" AND date="\'$date\'" AND firmw LIKE "\'$firmw\'" AND (ip<<"\'$ip\'" OR ip="\'$ip\'") \
       AND CAST(telnet AS TEXT) LIKE "\'$telnet\'" AND CAST(snmp AS TEXT) LIKE "\'$snmp\'")"
    fi
 done
}

fun_CONF () {
OLDIFS=$IFS
IFS=','
for ip in $net
 do
  echo IP/NET: $ip
  IFS=$OLDIFS
       fun_psql "SELECT * FROM conf WHERE (script LIKE "\'$script\'" AND date="\'$date\'" AND (ip<<"\'$ip\'" OR ip="\'$ip\'") \
       AND success="\'$success\'")"
 done
}


fun_tabscan () {
count=0
telnet="%"
snmp="%"
net="0.0.0.0/0"
model="%"
firmw="%"
date="now()"


check_arg () {
[[ "$OPTARG" =~ - ]] && { unset OPTARG && ((OPTIND=OPTIND-1));}
}

while getopts "m:n:f:t:s:n:c:hd:" Opts
  do
     check_arg
     case $Opts in
        m) model="$OPTARG";;
	n) net="$OPTARG";;
	f) firmw="$OPTARG";;
	t) telnet="$OPTARG";;
	s) snmp="$OPTARG";;
	c) count=1;COLUMN_SORT=$OPTARG;;
        d) date="$OPTARG";;
     esac
  done
fun_SCAN

}

fun_tabconf () {
script="%"
success="1"
net="0.0.0.0/0"
date="now()"

while getopts "s:S:n:d:" Opts
  do
     case $Opts in
        s) script="$OPTARG";;
	S) success="$OPTARG";;
	n) net="$OPTARG";;
	d) date="$OPTARG";;
     esac
done
fun_CONF
}

while getopts "SCh" Opts
  do
     case $Opts in
        S) fun_tabscan $*;;
	C) fun_tabconf $*;;
	h) fun_help;;
     esac
  done
