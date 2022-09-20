#!/bin/bash
#CREATE TABLE conf(script text,ip inet,success int,date date,time time);
WORKDIR="/usr/script_net"
. $WORKDIR/NetFUNCTION.sh

fun_help () {
script=`(basename $0)`
echo "
 -n -{file|172.19.0.13/32}
 -m -model
 -f -firmware
 -t -telnet{1|0}
 -s -snmp{1|0}
 -d -оключение сортировки только по текущей дате.
 -S -script, если вернёт значение 100 тогда будет считаться удачно выполненным.

example:
$(basename $0) -m \%E\%S\%35\% -S /usr/script_net/EdgeCore_chang-tacacs-R_ALL.exp &>/tmp/edgecore.log
$(basename $0) -m DES\%1210\%28ME -S /usr/script_net/DLink_chang-tacacs-R_ALL.exp &>/tmp/dlink1210.log
$(basename $0) -m DES\%3200\%10 -S /usr/script_net/DLink_chang-tacacs-R_ALL.exp &>/tmp/dlink3200.log
"
exit 0
}

fun_getip () {
OLDIFS=$IFS
IFS=','
for ip in `(echo "$net" | sed '/\//! s/$/\/32/g' | tr '\n' ',' | sed 's/,$//g' )`
 do
   IFS=$OLDIFS
   fun_psql "SELECT * FROM scan WHERE (model LIKE "\'$model\'" AND firmw LIKE "\'$firmw\'" AND (ip<<"\'$ip\'" OR ip="\'$ip\'") \
    AND CAST(telnet AS TEXT) LIKE "\'$telnet\'" AND CAST(snmp AS TEXT) LIKE "\'$snmp\'" $date_now)" "--tuples-only" | cut -f 1 -d "|" | sed  '/^$/d' | sed 's/ *//g'
 done
}

fun_CONF () {
yes=`(fun_psql "SELECT * FROM conf WHERE ip="\'$ip\'" AND script="\'$script_name\'" AND success='100'" "--tuples-only" | sed '/^$/d')`
[ ! -z "$yes" ] && { echo "Скрипт $script выполнялся ранее на ip $ip.";return 0;}
$script $ip
ret=$?
fun_psql "INSERT INTO conf(script,ip,success,date,time) VALUES ("\'$script_name\'","\'$ip\'","\'$ret\'",'now()','now()')"
}

fun_checkpack

telnet="%"
snmp="%"
unset net
model="%"
firmw="%"
date_now="AND date='now()'"
net='0.0.0.0/0'
[ -f "$net" ] && net=`(grep -v "#" $net | cut -f 1 -d ";" | sed '/\//! s/$/\/32/g' | tr '\n' ',' | sed 's/,$//g')`
while getopts "m:n:f:t:s:dS:h" Opts
  do
     case $Opts in
        m) model="$OPTARG";;
        n) net="$OPTARG";;
        f) firmw="$OPTARG";;
        t) telnet="$OPTARG";;
        s) snmp="$OPTARG";;
        d) unset date_now;;
	S) script="$OPTARG";;
	h) fun_help;;
     esac
  done

[ -z "$script" ] && { echo "Не указан script.";exit 1;}
[ ! -f "$script" ] && { echo "Нет файла $script.";exit 1;}
[ ! -r "$script" ] && { echo "Нет прав на чтение $script.";exit 1;}
[ ! -x "$script" ] && { echo "Не исполняемый файл $script.";exit 1;}
script_name=`(basename $script)`
for ip in `(fun_getip)`
do
 ((i=i+1))
 fun_CONF
 (($i%10)) || wait
done
wait
