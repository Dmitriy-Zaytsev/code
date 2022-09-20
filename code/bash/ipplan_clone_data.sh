#!/bin/bash
#echo "`(basename $0)` 172.19.1.131/21 172.19.7.254/21"
IP_OLD=$1
IP_NEW=$2
user_ipplan=ipplan
password_ipplan=ipplan
host_ipplan=192.168.33.2
db_ipplan=ipplan

date_ipplan=`(date "+%Y-%m-%d %H:%M:%S")`

MYSQL="mysql --user=$user_ipplan --password=$password_ipplan --host=$host_ipplan $db_ipplan --skip-column-names"
#MYSQL="mysql --user=$user_ipplan --password=$password_ipplan --host=$host_ipplan $db_ipplan"

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



baseindex_ip_old=`(echo "select baseindex from base WHERE inet_ntoa(baseaddr)='${net_old%%/*}' and subnetsize='$hosts_old';" | $MYSQL)`
baseindex_ip_new=`(echo "select baseindex from base WHERE inet_ntoa(baseaddr)='${net_new%%/*}' and subnetsize='$hosts_new';" | $MYSQL)`
[ -z "$baseindex_ip_old" ] && echo "Не существует подсети $IP_OLD в ipplan-е." && exit 2
[ -z "$baseindex_ip_new" ] && echo "Не существует подсети $IP_NEW в ipplan-е." && exit 2

data_ip_old=`(echo "select userinf,location,telno,macaddr,descrip,hname from ipaddr where inet_ntoa(ipaddr)='$ip_old';" | $MYSQL | tr '\t' ',' | sed "s/,/'&'/g" | sed -E  "s/(^|$)/'/g" | sed -E "s/^/INET_ATON('$ip_new'),/g")`
[[ -z `(echo "$data_ip_old" | sed -E  "s/('|,)//g")` ]] && echo "Нет данных $ip_old в ipplan-е." && exit 2
data_ip_new=`(echo "SELECT * FROM ipaddr WHERE baseindex='$baseindex_ip_new' AND ipaddr=INET_ATON('$ip_new')" | $MYSQL)`
[[ -n `(echo "$data_ip_new" | sed -E "s/ {1,99}/ /g" | tr -d '\t')` ]] && echo "Данные уже есть $ip_new в ipplan-е." && exit 2

echo "\
INSERT INTO ipaddr
(ipaddr,userinf,location,telno,macaddr,descrip,hname,baseindex,lastmod,userid)
VALUES
($data_ip_old,$baseindex_ip_new,'$date_ipplan','script');\
" | $MYSQL

