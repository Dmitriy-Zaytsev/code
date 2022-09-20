#!/bin/bash
ip=$1
com=$2
snmp_community='
kp2x45dv8v
ghbitktw'

oid_sysname='.1.3.6.1.2.1.1.5.0'
oid_ifDesc='.1.3.6.1.2.1.2.2.1.2'
oid_ifAlias='.1.3.6.1.2.1.31.1.1.1.18'
oid_ifOperStatus='.1.3.6.1.2.1.2.2.1.8'
oid_ifAdminStatus='.1.3.6.1.2.1.2.2.1.7'
#oid_ifLastChange='.1.3.6.1.2.1.2.2.1.9'

tmp_file=/tmp/`(basename $0_$$_)`
tmp_desc=$tmp_file"DESC.tmp"
tmp_alias=$tmp_file"ALIAS.tmp"
tmp_oper=$tmp_file"OPER.tmp"
tmp_admin=$tmp_file"ADMIN.tmp"
#tmp_lastch=$tmp_file"LAST.tmp"


echo -en $ip/
#ping -c 1 -W 1 $ip &>/dev/null || { echo "No respone icmp from $ip" ;exit 1;}
#for com in `(echo $snmp_community)`
# do
#  snmpget -c $com -v 2c $ip -r 0 -t 0.7  $oid_sysname -Oqv 2>/dev/null && break
# done



snmpwalk -c $com -v 2c $ip -r 0 -t 1  $oid_ifDesc  2>/dev/null | grep -v -E -i "(vlan|instance)" | grep -E -i "(ethernet|gigab|ten)" | sed 's/.*\.\([[:digit:]]*\) = STRING: \(.*\)/\1;\2/g' | sed -E "s/ {1,9}/_/g" 2>/dev/null >$tmp_desc &
##echo -e "`(echo "$IFDESC" | sed 's/;/\t/g')`"
snmpwalk -c $com -v 2c $ip -r 0 -t 1  $oid_ifAlias  2>/dev/null | sed 's/.*\.\([[:digit:]]*\) = STRING: \(.*\)/\1;\2/g' 2>/dev/null >$tmp_alias &
snmpwalk -c $com -v 2c $ip -r 0 -t 1  $oid_ifOperStatus  2>/dev/null | sed 's/.*\.\([[:digit:]]*\) = INTEGER: \(.*\)/\1;\2/g' 2>/dev/null >$tmp_oper &
snmpwalk -c $com -v 2c $ip -r 0 -t 1  $oid_ifAdminStatus  2>/dev/null | sed 's/.*\.\([[:digit:]]*\) = INTEGER: \(.*\)/\1;\2/g' 2>/dev/null >$tmp_admin &
#snmpwalk -c $com -v 2c $ip -r 0 -t 1  $oid_ifLastChange  2>/dev/null | sed 's/.*\.\([[:digit:]]*\) = Timeticks: \(.*\)/\1;\2/g' 2>/dev/null >$tmp_lastch &

wait
IFDESC=`(cat $tmp_desc)`
IFALIAS=`(cat $tmp_alias)`
IFOPERSTATUS=`(cat $tmp_oper)`
IFADMINSTATUS=`(cat $tmp_admin)`
IFLASTCHANGE=`(cat $tmp_lastch)`



unset TABLE
#TABLE='DESCR\tALIAS\tOPERST\tADMINST\tLASTCHAN'
TABLE='DESCR\tALIAS\tOPERST\tADMINST'
OLDIFS=$IFS
IFS=$'\n'
for line in `(echo "$IFDESC")`
 do
  index=`(echo $line | cut -f 1 -d ";")`
  descr=`(echo $line | cut -f 2 -d ";")`
  alias=`(echo "$IFALIAS" | grep  "^$index;" | cut -f 2 -d ";")`
  operstatus=`(echo "$IFOPERSTATUS" | grep  "^$index;" | cut -f 2 -d ";" | tr -dc 'a-zA-Z')`
  adminstatus=`(echo "$IFADMINSTATUS" | grep  "^$index;" | cut -f 2 -d ";" | tr -dc 'a-zA-Z')`
  #lastchang=`(echo "$IFLASTCHANGE" | grep  "^$index;" | cut -f 2 -d ";" | sed 's/(.*) //g' |  sed -E "s/ {1,50}//g")`
  alias=${alias:-'_'};descr=${descr:-'_'};operstatus=${operstatus:-'_'};adminstatus=${adminstatus:-'_'}; #lastchang=${lastchang:-'_'};
  #echo "INDEX:$index DESCR:$descr ALIAS:$alias IFOPERSTATUS:$operstatus IFADMINSTATUS:$adminstatus IFLASTCHANGE:$lastchang"
  #TABLE="$TABLE\n$descr\t$alias\t$operstatus\t$adminstatus\t$lastchang"
  TABLE="$TABLE\n$descr\t$alias\t$operstatus\t$adminstatus"
 done
IFS=$OLDIFS
echo -e "$TABLE" | column -t

#rm $tmp_desc $tmp_alias $tmp_oper $tmp_admin $tmp_lastch
rm $tmp_desc $tmp_alias $tmp_oper $tmp_admin
