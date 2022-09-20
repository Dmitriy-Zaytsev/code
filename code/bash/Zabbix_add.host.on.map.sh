#!/bin/bash
#Добавление на карту(родную zabbix-овскую) хостов которые enable и есть snmp interface, по группе на одноимённую карту, для того что бы не разносить в ручную по картам.
#Скрипт в прадашене на последний момент не использовался.
host_id=`(sudo -u zabbix psql zabbix -c "SELECT hostid,host FROM hosts WHERE status=0 AND snmp_available=1;" | grep -v hostid | sed  -E 's/ {1,9}//g' | sed 's/|/;/g' | sed -E '/--|row|^$/d')`

#Разрешённые карты
MAP='
core
NG
GES
ZJB'

#del host on map


#add host on map
for host_id_line in $host_id
do
 hostid=`( echo $host_id_line | cut -d ";" -f "1")`
 hostip=`(echo $host_id_line | cut -d ";" -f "2")`
 groupid=`(sudo -u zabbix psql zabbix -c "SELECT groupid FROM hosts_groups WHERE hostid='$hostid';"| \
grep -v groupid | sed -E '/--|row|^$/d' | tr '\n' ' ' | sed -E 's/\ $//g' | sed -E 's/ {1,50}/;/g' |  sed -E 's/^;//g')`
echo ++++
echo HOSTID:$hostid HOSTIP:$hostip GROUPID:$groupid
 unset ALLMAPID
 for gid in `(echo $groupid | tr ';' '\n' | tr -d ' ')`
  do
   groupname=`(sudo -u zabbix psql zabbix -c "SELECT name FROM groups WHERE groupid='$gid';" | sed -E '/--|row|^$|name/d' | sed 's/^ //g' )`
     echo -e "\tGROUPID:$gid GROUPNAME:$groupname"
     mapid=`(sudo -u zabbix psql zabbix -c "SELECT sysmapid FROM sysmaps WHERE name='$groupname';" | sed -E '/--|row|^$|sysmapid/d' | sed 's/ //g')`
     [ -z "$mapid" ] && { echo -e "\t\tНет карты $groupname";continue;}
      ALLMAPID="$ALLMAPID|$mapid"
      access=0
      for map in $MAP
      do
         [ "$groupname" = "$map" ] && access=1
      done
     [ "$access" = "0" ] && { echo -e "\t\tЕсть карта $groupname, но в неё не разрешенно заносить хосты";continue;}
     echo -e "\t\tЕсть карта $groupname"
yesmap=`(sudo -u zabbix psql zabbix -c "\
SELECT elementid FROM sysmaps_elements WHERE elementid='$hostid' AND sysmapid='$mapid'" | sed -E '/--|row|^$|elementid/d';)`
[ ! -z "$yesmap" ] && { echo -e "\t Есть  $hostip на карте $groupname";continue;}
x=10;y=10
 while true
       do
	yesxy=`(sudo -u zabbix psql zabbix -c "SELECT elementid FROM sysmaps_elements WHERE (x=$x AND y=$y AND sysmapid='$mapid');" | sed -E '/--|row|^$|elementid/d';)`
        [ -z "$yesxy" ] && break
        ((x=x+40));((y=y+40))
       done


maxelementid=`(sudo -u zabbix psql zabbix -c "\
SELECT selementid FROM sysmaps_elements ORDER BY selementid DESC LIMIT 1;" | sed -E '/--|row|^$|elementid/d' | sed -E 's/ {1,50}//g')`
((maxelementid=maxelementid+1))
[ "$maxelementid"  -lt 700 ] && ((maxelementid=maxelementid+700))

sudo -u zabbix psql zabbix -c "\
INSERT INTO sysmaps_elements(selementid,sysmapid,elementid,elementtype,iconid_off,x,y,elementsubtype,areatype,width,height,use_iconmap) \
VALUES ($maxelementid,$mapid,$hostid,0,151,$x,$y,0,1,302,302,1);"

  done

CURRENT_ALLMAPID=`(sudo -u zabbix psql zabbix -c "\
SELECT sysmapid FROM sysmaps_elements WHERE elementid='$hostid';" | sed -E '/--|row|^$|sysmapid/d';)`
DELETE_HOSTONMAP=`(echo $CURRENT_ALLMAPID | sed -E "s/$ALLMAPID//g")`

for delhostmap in `(echo $DELETE_HOSTONMAP | tr ' ' '\n')`
do
 echo "Удаление $hostid:$hostip с карты $delhostmap"
 sudo -u zabbix psql zabbix -c "\
 DELETE FROM sysmaps_elements WHERE  elementid='$hostid' AND sysmapid='$delhostmap';"
done

done
