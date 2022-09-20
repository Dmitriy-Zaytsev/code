#!/bin/bash
LOG_FILE=/tmp/"$USER"_`(basename $0)`.log

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
export ro_community=ghbitktw
export rw_community=nL18siBq87pq13
export version_snmp="2c"
export SNMPGET="snmpget -t 1 -r 1 -c $ro_community -v $version_snmp -Oqnv"
export SNMPSET="snmpset -t 1 -r 1 -c $rw_community -v $version_snmp -Oqnv"
#-
username_telnet=sa0405nch
password_telnet=dwGynns5vD
#-
manvlan=801
#---------var---------

ipplan=enable
[ "$1" = "-c" ] && fun_packet && exit 0
[ "$1" = "-h" ] && fun_help && exit 0
[ "$#" -lt "2" ] && fun_log "ERROR" "Недостаточно параметров" && fun_help && exit 2
[[ "$@" =~ "-d" ]] && ipplan=disable
ipplan=disable


fun_log "INFO" "Запуск `(basename $0)` $IP_OLD $IP_NEW"

#+++++++++ipcalc+++++++++
ipcalc="`(ipcalc -n "$IP_OLD")`"
export gw_old=`(echo "$ipcalc" | grep HostMin | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
export net_old=`(echo "$ipcalc" | grep Network | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
export ip_old="${IP_OLD%%/*}"
export mask_old=`(echo "$ipcalc" | grep Netmask | sed "s/Netmask: *\(.*\) =.*/\1/g")`
export hosts_old=`(echo "$ipcalc" | grep Hosts | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
((hosts_old=$hosts_old+2))

ipcalc="`(ipcalc -n "$IP_NEW")`"
export gw_new=`(echo "$ipcalc" | grep HostMin | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
export net_new=`(echo "$ipcalc" | grep Network | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
export ip_new="${IP_NEW%%/*}"
export mask_new=`(echo "$ipcalc" | grep Netmask | sed "s/Netmask: *\(.*\) =.*/\1/g")`
export hosts_new=`(echo "$ipcalc" | grep Hosts | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
((hosts_new=$hosts_new+2))
#---------ipcalc---------
> /srv/ftp/dumped/"$ip_old".cfg
chown ftp:nogroup /srv/ftp/dumped/"$ip_old".cfg
chmod 777 /srv/ftp/dumped/"$ip_old".cfg

#+++++++++ping/nmap+++++++++
ping -c 1 $ip_old -W 1 &>/dev/null || { fun_log "ERROR" "Не доступен IP_OLD:$ip_old" && exit 3;}
nmap -p 32 $ip_old -sT -T5 &>/dev/null || { fun_log "ERROR" "Закрыт порт 21 telnet IP_OLD:$ip_old ." && exit 3;}
ping -c 1 $ip_new -W 1 &>/dev/null && { fun_log "ERROR" "Уже занят IP_NEW: $ip_new" && exit 3;}
[ "ipplan" = "enable" ] && { nmap -p 3306 $host_ipplan -sT -T5 &>/dev/null || { fun_log "ERROR" "Закрыт порт 3306 mysql." && exit 3;};}
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
export ip_oid="$sysObjectID.2.2.0 a"
export mask_oid="$sysObjectID.2.3.0 a"
export gw_oid="$sysObjectID.2.4.0 a"
export save_oid="$sysObjectID.1.10.0 i"
}

fun_607B039 () {
sysObjectID=".1.3.6.1.4.1.171.10.75.15.2"
export ip_oid="$sysObjectID.2.2.0 a"
export mask_oid="$sysObjectID.2.3.0 a"
export gw_oid="$sysObjectID.2.4.0 a"
export save_oid="$sysObjectID.1.10.0 i"
}


fun_D_1210-10ME_B2 () {
firmware_oid="$sysObjectID.1.3.0"
firmware=`($SNMPGET $ip_old $firmware_oid 2>/dev/null)`
case "$firmware" in
  *10.04.B036* ) vendor=dlink;fun_1004B036; \
script="./D_1210-10_pre-chang-ip.exp $ip_old $username_telnet $password_telnet $rw_community $version_snmp && { ./D_1210-10_chang-ip.sh && ./D_1210-10_post-chang-ip.exp $ip_new $username_telnet $password_telnet || ./D_1210-10_post-chang-ip.exp $ip_old $username_telnet $password_telnet;}";;
  * ) fun_log "ERROR" "Неизвестная версия прошивки FIRMWARE:$firmware SYSDESCR:$sysDescr IP_OLD:$ip_old." && exit 6;;
esac
}

fun_D_DES-1210-28ME () {
firmware_oid="$sysObjectID.1.3.0"
firmware=`($SNMPGET $ip_old $firmware_oid 2>/dev/null)`
case "$firmware" in
  * ) vendor=dlink;fun_607B039; \ 
script="./D_DES-1210-28_pre-chang-ip.exp $ip_old $username_telnet $password_telnet $rw_community $version_snmp && { ./D_DES-1210-28_chang-ip.sh && ./D_DES-1210-28_post-chang-ip.exp $ip_new $username_telnet $password_telnet || ./D_DES-1210-28_post-chang-ip.exp $ip_old $username_telnet $password_telnet;}";;
  * ) fun_log "ERROR" "Неизвестная версия прошивки FIRMWARE:$firmware SYSDESCR:$sysDescr IP_OLD:$ip_old." && exit 6;;
esac
}


fun_D_3200-28_C1 () {
firmware_oid=".1.3.6.1.2.1.16.19.2.0"
firmware=`($SNMPGET $ip_old $firmware_oid 2>/dev/null)`
case "$firmware" in
  *4.44.B001* ) ./DES-3200-28_disable_acl.exp $ip_old $rw_community $username_telnet $password_telnet ;; #&& { ./DES-3200-28_chan-ip.sh && ./DES-3200-28_enable_acl.exp;};;
  * ) fun_log "ERROR" "Неизвестная версия прошивки FIRMWARE:$firmware SYSDESCR:$sysDescr IP_OLD:$ip_old." && exit 6;;
esac
}


#--------detect_oid_snmp---------


#+++++++++detect_model_device+++++++++
case "$sysDescr" in
  *DES-1210-10*ME* ) fun_D_DES-1210-28ME;;
  *DES-1210-28*ME* ) fun_D_DES-1210-28ME;;
  *ES3510MA*|*3528*|*3552*|*3510* ) script="./E_MODEL_chang-ip.exp $ip_old $ip_new $mask_new $gw_new $username_telnet $password_telnet $manvlan";;
  #*DES-3200-28/C1* ) fun_dlink3200-28C1;;
  * ) fun_log "ERROR" "Неизвестная модель SYSDESCR:$sysDescr IP_OLD:$ip_old." && exit 4;;
esac
#--------detect_model_device---------

#++++++++change_ip+++++++++
echo "$script" | /bin/bash
ret=$?
if [ "$ret" = "0" ] && { ping -c 3 -W 3 $ip_new &>/dev/null && ! ping -c 1 -W 1 $ip_old &>/dev/null;}
  then
    ret=$?
    [ "$ret" = "1" ] && fun_log "WARNING" "Не удалось войти по telnet для включения acl IP_NEW:$ip_new." && exit 7
    [ "$ret" = "40" ] && fun_log "WARNING" "Не определён управляющий vlan." && exit 7
    [ "$ret" = "30" ] && fun_log "WARNING" "Истекло время ожиданя по telnet для включения acl IP_NEW:$ip_new." && exit 7
  else
   fun_log "ERROR" "Не удалось сменить ip IP_OLD:$ip_old на IP_NEW:$ip_new." && exit 8
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
