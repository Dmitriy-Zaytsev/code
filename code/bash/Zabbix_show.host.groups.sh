#!/bin/bash
#В каких группах host-ы c snmp истатусом enable.
host_id=`(sudo -u zabbix psql zabbix -h /var/run/postgresql -p 5432 -c "SELECT hostid,host FROM hosts WHERE status=0 AND snmp_available=1;" | grep -v hostid | sed  -E 's/ {1,9}//g' | sed 's/|/;/g' | sed -E '/--|row|^$/d')`


for host_id_line in $host_id
do
 hostid=`( echo $host_id_line | cut -d ";" -f "1")`
 hostip=`(echo $host_id_line | cut -d ";" -f "2")`
 groupid=`(sudo -u zabbix psql zabbix -h /var/run/postgresql -p 5432 -c "SELECT groupid FROM hosts_groups WHERE hostid='$hostid';"| \
grep -v groupid | sed -E '/--|row|^$/d' | tr '\n' ' ' | sed -E 's/\ $//g' | sed -E 's/ {1,50}/;/g' |  sed -E 's/^;//g')`
echo ++++
echo HOSTID:$hostid HOSTIP:$hostip GROUPID:$groupid
 for gname in `(echo $groupid | tr ';' '\n')`
  do
   groupname=`(sudo -u zabbix psql zabbix -h /var/run/postgresql -p 5432 -c "SELECT name FROM groups WHERE groupid='$gname';" | sed -E '/--|row|^$|name/d')`
     echo -e "\tGROUPID:$gname GROUPNAME:$groupname"
  done
done
