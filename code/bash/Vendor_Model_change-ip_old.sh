#!/bin/bash
LOG_FILE=/tmp/$USER_`(basename $0)`.log

fun_help () {
echo "
Help:
`(basename $0)` ip_old ip_new
Example:
`(basename $0)` 172.19.5.254 172.19.7.254/24
`(basename $0)` -h #help
`(basename $0)` -c #Проверка наличия пакетов
`(basename $0)` 172.19.5.254 172.19.7.254/24 -d #Не вносить изменения в ipplan.
"
}

fun_packet () {
packages='
ipcalc
nmap
snmp
expect
'
for pack in $packages
 do
  dpkg-query -s $pack &>/dev/null || { echo "ERROR: Не установлен пакет $pack" && exit 2;}
 done
echo "INFO: Все пакеты установленны."
}

fun_log () {
level="$1" #INFO,WARNING,ERROR
message="$2"
progname=`(basename $0)`
date=`(date "+%d/%m/%y_%H:%M:%S")`
echo "$date [$level]: $message" | tee -a $LOG_FILE
}

#+++++++++var+++++++++
IP_OLD=$1
IP_NEW=$2
#-
user_ipplan=ipplan
password_ipplan=ipplan
host_ipplan=192.168.33.2
db_ipplan=ipplan
MYSQL="mysql --user=$user_ipplan --password=$password_ipplan --host=$host_ipplan $db_ipplan --skip-column-names"
#-
ro_community=ghbitktw
rw_community=nL18siBq87pq13
version_snmp="2c"
SNMPGET="snmpget -t 1 -r 1 -c $ro_community -v $version_snmp -Oqnv"
SNMPSET="snmpset -t 1 -r 1 -c $rw_community -v $version_snmp -Oqnv"
#-
username_telnet=sa0405nch
password_telnet=dwGynns5vD
#---------var---------

ipplan=enable
[ "$1" = "-c" ] && fun_packet && exit 0
[ "$1" = "-h" ] && fun_help && exit 0
[ "$#" -lt "2" ] && fun_log "ERROR" "Недостаточно параметров" && fun_help && exit 2
[[ "$@" =~ "-d" ]] && ipplan=disable

fun_log "INFO" "Запуск `(basename $0)` $IP_OLD $IP_NEW"

#+++++++++ipcalc+++++++++
ipcalc="`(ipcalc -n "$IP_OLD")`"
gw_old="`(echo "$ipcalc" | grep HostMin | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`"
net_old="`(echo "$ipcalc" | grep Network | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`"
ip_old="${IP_OLD%%/*}"
mask_old="`(echo "$ipcalc" | grep Netmask | sed "s/Netmask: *\(.*\) =.*/\1/g")`"
hosts_old="`(echo "$ipcalc" | grep Hosts | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`"
((hosts_old=$hosts_old+2))

ipcalc="`(ipcalc -n "$IP_NEW")`"
gw_new="`(echo "$ipcalc" | grep HostMin | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`"
net_new="`(echo "$ipcalc" | grep Network | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`"
ip_new="${IP_NEW%%/*}"
mask_new="`(echo "$ipcalc" | grep Netmask | sed "s/Netmask: *\(.*\) =.*/\1/g")`"
hosts_new="`(echo "$ipcalc" | grep Hosts | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`"
((hosts_new=$hosts_new+2))
#---------ipcalc---------

#+++++++++ping/nmap+++++++++
ping -c 1 $ip_old -W 1 &>/dev/null || { fun_log "ERROR" "Не доступен IP_OLD:$ip_old" && exit 3;}
nmap -p 32 $ip_old -sT -T5 &>/dev/null || { fun_log "ERROR" "Закрыт порт 21 telnet IP_OLD:$ip_old ." && exit 3;}
ping -c 1 $ip_new -W 1 &>/dev/null && { fun_log "ERROR" "Уже занят IP_NEW: $ip_new" && exit 3;}
nmap -p 3306 $host_ipplan -sT -T5 &>/dev/null || { fun_log "ERROR" "Закрыт порт 3306 mysql." && exit 3;}
#--------ping/nmap---------

#+++++++++ipplan/mysql+++++++++
if [ "$ipplan" = "enable" ]
  then
baseindex_ip_old=`(echo "select baseindex from base WHERE inet_ntoa(baseaddr)='${net_old%%/*}' and subnetsize='$hosts_old';" | $MYSQL)`
baseindex_ip_new=`(echo "select baseindex from base WHERE inet_ntoa(baseaddr)='${net_new%%/*}' and subnetsize='$hosts_new';" | $MYSQL)`
[ -z "$baseindex_ip_old" ] && { fun_log "ERROR" "Не существует подсети IP_OLD:$IP_OLD в ipplan-е." && exit 4;}
[ -z "$baseindex_ip_new" ] && { fun_log "ERROR" "Не существует подсети IP_NEW:$IP_NEW в ipplan-е." && exit 4;}
#-
data_ip_old=`(echo "select userinf,location,telno,macaddr,descrip,hname from ipaddr where inet_ntoa(ipaddr)='$ip_old';" | $MYSQL | tr '\t' ',' | sed "s/,/'&'/g" | sed -E  "s/(^|$)/'/g" | sed -E "s/^/INET_ATON('$ip_new'),/g")`
[[ -z `(echo "$data_ip_old" | sed -E  "s/('|,)//g")` ]] && { fun_log "EROR" "Нет данных IP_OLD:$ip_old в ipplan-е." && exit 4;}
data_ip_new=`(echo "SELECT * FROM ipaddr WHERE baseindex='$baseindex_ip_new' AND ipaddr=INET_ATON('$ip_new')" | $MYSQL)`
[[ -n `(echo "$data_ip_new" | sed -E "s/ {1,99}/ /g" | tr -d '\t')` ]] && { fun_log "ERROR" "Данные уже есть IP_NEW:$ip_new в ipplan-е." && exit 4;}
fi
#--------ipplan/mysql---------

#+++++++++snmp+++++++++
sysDescr=`($SNMPGET $ip_old .1.3.6.1.2.1.1.1.0 2>/dev/null)`
[ -z "$sysDescr" ] && { fun_log "ERROR" "Нет ответа по snmp IP_OLD:$ip_old." && exit 5;}
sysName=`($SNMPGET $ip_old .1.3.6.1.2.1.1.5.0 2>/dev/null)`
sysName=${sysName:-Hostname}
sysObjectID=`($SNMPGET $ip_old .1.3.6.1.2.1.1.2.0 2>/dev/null)`
[ -z "$sysObjectID" ] && { fun_log "ERROR" "Не удалось получить приватную ветку IP_OLD:$ip_old SYSDESCR:$sysDescr SYSNAME:$sysName." && exit 5;}
#--------snmp---------


#+++++++++detect_oid_snmp+++++++++
fun_1004B036 () {
ip_oid="$sysObjectID.2.2.0 a"
mask_oid="$sysObjectID.2.3.0 a"
gw_oid="$sysObjectID.2.4.0 a"
save_oid="$sysObjectID.2.4.0 i"
}

fun_dlink1210-10MEB2 () {
firmware_oid="$sysObjectID.1.3.0"
firmware=`($SNMPGET $ip_old $firmware_oid 2>/dev/null)`
case "$firmware" in
  *10.04.B036* ) vendor=dlink;fun_1004B036;;
  * ) fun_log "ERROR" "Неизвестная версия прошивки FIRMWARE:$firmware SYSDESCR:$sysDescr IP_OLD:$ip_old." && exit 6;;
esac
}
#--------detect_oid_snmp---------

#+++++++++script_expect+++++++++
fun_dlink-disable-acl () {
ip=$ip_old
username=$username_telnet
password=$password_telnet
timeout=1
time=10
/usr/bin/expect <<EOD
set send_human {0.01 .00001 1 .000001 5}
spawn telnet $ip
set u 0
set p 0
while 1 {
expect {
"Login:.*" {send "$username\r";incr u +1}
"login:" {send "$username\r";incr u +1}
"username:" {send "$username\r";incr u +1}
"Username:" {send "$username\r";incr u +1}
"UserName:" {send "$username\r";incr u +1}
"Password:" {send "$password\r";incr p +1}
"password:" {send "$password\r";incr p +1}
"#" {send "\r";break}
">" {send "enable\r"; expect "Password" {send "$password\r";break}}
}
if { "$u" == "2" && "$p" == "2" } {set username rabbit; set password rabbit}
if { "$u" == "5" && "$p" == "5" } {exit 1}
}
set i 0
while 1 {expect "#" {send -h "disable clipaging\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "disable trust\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "create snmp user mts_rw ReadWrite v$version_snmp\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "create snmp community $rw_community mts_rw\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "logout\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
exit 0
expect "sdfsdf"
EOD
ret=$?
return $ret
}

fun_dlink-enable-acl () {
ip=$ip_new
username=$username_telnet
password=$password_telnet
timeout=1
time=10
/usr/bin/expect <<EOD
set send_human {0.01 .00001 1 .000001 5}
spawn telnet $ip
set u 0
set p 0
while 1 {
expect {
"Login:.*" {send "$username\r";incr u +1}
"login:" {send "$username\r";incr u +1}
"username:" {send "$username\r";incr u +1}
"Username:" {send "$username\r";incr u +1}
"UserName:" {send "$username\r";incr u +1}
"Password:" {send "$password\r";incr p +1}
"password:" {send "$password\r";incr p +1}
"#" {send "\r";break}
">" {send "enable\r"; expect "Password" {send "$password\r";break}}
}
if { "$u" == "2" && "$p" == "2" } {set username rabbit; set password rabbit}
if { "$u" == "5" && "$p" == "5" } {exit 1}
}
set i 0
while 1 {expect "#" {send -h "enable clipaging\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "enable trust\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "save\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "logout\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
exit 0
expect "sdfsdf"
EOD
ret=$?
return $ret
}

fun_edgecore () {
ip=$ip_old
username=$username_telnet
password=$password_telnet
timeout=1
time=10
/usr/bin/expect <<EOD
set send_human {0.01 .00001 1 .000001 5}
spawn telnet $ip
set u 0
set p 0
while 1 {
expect {
"Login:.*" {send "$username\r";incr u +1}
"login:" {send "$username\r";incr u +1}
"username:" {send "$username\r";incr u +1}
"Username:" {send "$username\r";incr u +1}
"UserName:" {send "$username\r";incr u +1}
"Password:" {send "$password\r";incr p +1}
"password:" {send "$password\r";incr p +1}
"#" {send "\r";break}
">" {send "enable\r"; expect "Password" {send "$password\r";break}}
}
if { "$u" == "2" && "$p" == "2" } {set username rabbit; set password rabbit}
if { "$u" == "5" && "$p" == "5" } {exit 1}
}
set i 0
set timeout 1
while 1 {expect "#" {send -h "term len 0\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "show ip interface\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
expect "#" { set out $expect_out(buffer);send "\r"}
send_user "$out\n\n\n"
set ret [regexp -nocase {VLAN ([0-9]*) is.*Up} $out str vlan]
if { "$ret" == "1" } {exit 40}
while 1 {expect "#" {send -h "configure\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "interface vlan \$vlan\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "ip address $ip_new $mask_new default-gateway $gw_new\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
send "exit\r"
exit 0
while 1 {expect "#" {send -h "\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
while 1 {expect "#" {send -h "logout\r";break};if { "$i" >= "$time" } { set i 0;exit 30};incr i +1}
exit 0
expect "sdfsdf"
EOD
ret=$?
return $ret
}

#--------script_expect---------

#+++++++++detect_model_device+++++++++
case "$sysDescr" in
  *DES-1210-10*ME*B2* ) disable_acl=fun_dlink-disable-acl;enable_acl=fun_dlink-enable-acl;fun_dlink1210-10MEB2;;
  *ES3510MA* )fun_edgecore;;
  * ) fun_log "ERROR" "Неизвестная модель SYSDESCR:$sysDescr IP_OLD:$ip_old." && exit 4;;
esac
#--------detect_model_device---------

#++++++++change_ip+++++++++
if [[ "1210" =~ "$sysDescr" ]]
 then
fun_log "INFO" "Отключение acl IP_OLD:$ip_old SYSDESCR:$sysDescr"
$disable_acl $ip_old
ret=$?
[ "$ret" = "1" ] && fun_log "ERROR" "Не удалось войти по telnet для отключения acl IP_OLD:$ip_old." && exit 7
[ "$ret" = "30" ] && fun_log "ERROR" "Истекло время ожиданя по telnet для отключения acl IP_OLD:$ip_old." && exit 7

fun_log "INFO" "Перевод через snmpset IP_OLD:$ip_old IP_NEW:$ip_old MASK_NEW:$mask_new GW_NEW:$gw_new"
$SNMPSET $ip_old \
$ip_oid $ip_new \
$mask_oid $mask_new \
$gw_oid $gw_new #$save_oid 1


if ping -c 3 -W 3 $ip_new &>/dev/null && ! ping -c 1 -W 1 $ip_old &>/dev/null
  then
    fun_log "INFO" "Включение acl IP_OLD:$ip_old SYSDESCR:$sysDescr"
    $enable_acl $ip_new
    ret=$?
    [ "$ret" = "1" ] && fun_log "WARNING" "Не удалось войти по telnet для включения acl IP_NEW:$ip_new." && exit 7
    [ "$ret" = "30" ] && fun_log "WARNING" "Истекло время ожиданя по telnet для включения acl IP_NEW:$ip_new." && exit 7
  else
   fun_log "ERROR" "Не удалось сменить ip IP_OLD:$ip_old на IP_NEW:$ip_new." && exit 8
fi
fi
#---------change_ip---------

#+++++++++insert_mysql+++++++++
if [ "$ipplan" = "enable" ]
  then
fun_log "INFO" "Клонирование данных в ipplan IP_OLD:$ip_old IP_NEW:$ip_new."
date_ipplan=`(date "+%Y-%m-%d %H:%M:%S")`
echo "\
INSERT INTO ipaddr
(ipaddr,userinf,location,telno,macaddr,descrip,hname,baseindex,lastmod,userid)
VALUES
($data_ip_old,$baseindex_ip_new,'$date_ipplan','script');\
" | $MYSQL
ret=$?
[ ! "$ret" = "0" ] && fun_log "ERROR" "Не удалось внести данные в ipplan, IP_OLD:$ip_old IP_NEW:$ip_new." && exit 8
fi
#---------insert_mysql---------

fun_log "INFO" "Смена IP_OLD:$ip_old на IP_NEW:$ip_new прошла успешно."
