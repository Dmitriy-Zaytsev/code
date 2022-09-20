#!/bin/bash
#Добавляем hostname,а также координаты на хосты которые не отключены и отвечают по snmp.
###wget -S -O- --header "Content-Type: application/json" http://192.168.33.4/zabbix/api_jsonrpc.php --post-data='{"jsonrpc": "2.0","method": "host.get","params": {"output": ["hostid","host"...
#ID и AUTH нужно получить другим запросом.
ID="1987"
AUTH="119003ae6a54d5da2a56759cb5dff9ba"
IP='192.168.33.4'
API='http://'$IP'/zabbix/api_jsonrpc.php'
SNMP_COMM="\
ghbitktw
kp2x45dv8v
"
GROUP_ID="9" #=DEVICE (group)

fun_api () {
REQUEST=$1
HEADER='--header Content-Type:application/json'
POSTDATA='--post-data='$REQUEST''
#wget -S -O- $HEADER $API $POSTDATA $PARS
wget -S -O- $HEADER $API $POSTDATA 2>/dev/null
}

fun_jsonpars () {
echo $1 | tr -d '\n' | tr -d ' ' | tr -d '\t'
}


JSON='{
	"jsonrpc":"2.0",
	"method":"host.get",
	"params":{
		"output":["name","status","snmp_available","snmp_error"],
		"groupids": "'$GROUP_ID'",
		"selectInventory":["model","location_lat","location_lon"],
		"selectInterfaces":["ip","type"]
		},
	"id":'$ID',
	"auth":"'$AUTH'"
	}'
JSON=`(fun_jsonpars "$JSON")`
for string in `(fun_api "$JSON" | jq -M '.result[]' -c -S)`
do
export `(echo "$string" |  sed 's/"\|\[\|\]\|{\|}//g' | sed 's/:/=/g' | tr ',' '\n'| sed 's/.*=\(.*=.*\)/\1/g')`
echo "
hostid: $hostid
ip: $ip
type: $type
model: $model
name: $name
snmp_available: $snmp_available
snmp_error: $snmp_error
status: $status
latitude: $latitude
location_lat: $location_lat
location_lon: $location_lon
"

if [[ ! "$status" = "0" ]] || [[ ! -z "$snmp_error" ]] || [ ! "$snmp_available" = "1" ] || [ ! "$type" = "2" ]
then
 echo "!!! $name $ip отключен или не доступен по snmp."
 echo "+++"
 continue
fi
for COMM in `(echo "$SNMP_COMM")`
 do
   unset NAME
   NAME=`(snmpget -v 1 -c "$COMM" "$ip" sysName.0 -r 0 -t 1 -Oqnv 2>/dev/null | tr -d '"')`
   [[ "$NAME" =~ "UPS" ]] && NAME="`(echo $NAME | tr '[:upper:]' '[:lower:]')`"
   [ -n "$NAME" ] && break
 done
[ -z "$NAME" ] && NAME="$ip"
   JSON='{
        "jsonrpc":"2.0",
        "method":"host.update",
        "params":{
                "hostid":"'$hostid'",
                "name": "'$NAME'"
                },
        "id":'$ID',
        "auth":"'$AUTH'"
        }'
  JSON=`(fun_jsonpars "$JSON")`
if [ "$NAME" = "$name" ]
   then
	echo "!!! Смена имени у $name не требуеться."
	continue
fi
echo "!!! Смена имени с $name на $NAME."
fun_api "$JSON" &>/dev/null

done
