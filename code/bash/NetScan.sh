#!/bin/bash
COMMUNITY="ghbitktw kp2x45dv8v"
COMMUNITY=($COMMUNITY)
WORKDIR="/usr/script_net"
. $WORKDIR/NetFUNCTION.sh


fun_help () {
script=`(basename $0)`
echo "
-n -[file|ipaddress/cidr]
-h -help
-D -drop base
example:
`(basename $0)` -n /var/local/IP_acsw.txt

cat /var/local/IP_acsw.txt
#COMMENT
172.19.199.192/26;[DGS-1100_MGMT]
172.19.254.0/24;[Mangment_БШПД]
192.168.33.100
"
exit 0
}




fun_snmp () {
OID="$1"
for community in ${COMMUNITY[*]}
do
snmpget -c $community -v 2c -r 0 -t 1 $ip $OID -Oqvn 2>/dev/null && return 0
done
}



fun_model () {
case $model in
	ES3510MA) model=ES3510MA;;
	*ES3528M*) model=ES3528M;;
	*ES3552M*) model=ES3552M;;
	*ECS3510-28T*) model=ECS3510-28T;;
	*ECS3510-52T*) model=ECS3510-52T;;
	*DES-1210-28/ME* ) model=DES-1210-28ME;;
	Realtek-Switch. ) model=DGS-1100-08;;
	*DES-3200-10/C1* ) model=DES-3200-10;;
	*S2008-EI* ) model=S2008-EI;;
esac
}

fun_snmpvar_EdgeCore () {
oid_enterp=`(fun_snmp sysObjectID.0)`
sysname=`(fun_snmp sysName.0 | sed 's/ *//g')`
firmw=`(fun_snmp ""$oid_enterp".1.1.3.1.6.1" | sed 's/"//g')`
fun_model
}

fun_snmpvar_EdgeCore2 () {
#ECS3510-28/52M
sysname=`(fun_snmp sysName.0 |  sed 's/ *//g')`
firmw=`(fun_snmp ".1.3.6.1.4.1.259.10.1.27.1.1.3.1.6.1" | sed 's/"//g')`
fun_model
}


fun_snmpvar_Dlink () {
oid_enterp=`(fun_snmp sysObjectID.0)`
sysname=`(fun_snmp sysName.0 |  sed 's/ *//g')`
firmw=`(fun_snmp ""$oid_enterp".1.3.0" | sed 's/"//g')`
fun_model
}

fun_snmpvar_Dlink2 () {
sysname=`(fun_snmp sysName.0 |  sed 's/ *//g')`
firmw=`(fun_snmp ".1.3.6.1.2.1.16.19.2.0")`
fun_model
}

fun_snmpvar_DGS () {
unset sysname firmw
fun_model
}


fun_snmpvar_Huawei () {
oid_enterp=`(fun_snmp sysObjectID.0)`
unset sysname firmw
fun_model
}

fun_dropbase () {
fun_psql "DROP TABLE scan"
fun_psql "CREATE TABLE scan(ip inet UNIQUE,model text,firmw text,icmp int,telnet int,snmp int,sysname text,date date,time time)"
}

fun_checkpack

while getopts "n:hD" Opts
  do
     case $Opts in
        n) netaddress=$OPTARG;;
	D) fun_dropbase;;
	h) fun_help;;
     esac
  done

fun_FUN () {
fun_access || return 1
model=`(fun_snmp sysDescr.0)`
case "$model" in
        ES3510MA|\
        *ES3528M*|*ES3552M*) fun_snmpvar_EdgeCore;;
	*ECS3510-*) fun_snmpvar_EdgeCore2;;
        *DES-1210-28/ME*) fun_snmpvar_Dlink;;
	*DES-3200-10*) fun_snmpvar_Dlink2;;
	Realtek-Switch.) fun_snmpvar_DGS;;
	*S2008-EI*) fun_snmpvar_Huawei;;
esac
model=${model:-model}
firmw=${firmw:-firmw}
sysname=${sysname:-sysname}

echo "$ip;$model;$firmw;$icmp;$telnet;$snmp;$sysname;`(date "+%Y-%m-%d")`;`(date "+%H:%M:%S.%s")`"
fun_psql "INSERT INTO scan(ip,model,firmw,icmp,telnet,snmp,sysname,date,time) VALUES\
("\'$ip\'","\'$model\'","\'$firmw\'","\'$icmp\'","\'$telnet\'","\'$snmp\'","\'$sysname\'",'now()','now()')  ON CONFLICT (ip) DO UPDATE SET model=EXCLUDED.model,firmw=EXCLUDED.firmw,icmp=EXCLUDED.icmp,telnet=EXCLUDED.telnet,snmp=EXCLUDED.snmp,sysname=EXCLUDED.sysname,date=EXCLUDED.date,time=EXCLUDED.time"
}

i=0
for ip in `(fun_iprange $netaddress)`
do
 ((i=i+1))
 fun_FUN &
 (($i%30)) || wait
done
wait
