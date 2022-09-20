#!/bin/bash
ID="1987"
AUTH="119003ae6a54d5da2a56759cb5dff9ba"
IP='192.168.33.4'
API='http://'$IP'/zabbix/api_jsonrpc.php'
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

#type=2 = snmp interface.
JSON='{
        "jsonrpc":"2.0",
        "method":"host.get",
        "params":{
                "output": ["name","status","snmp_available","snmp_error"],
		"filter": {"type": "2"},
	        "groupids": "'$GROUP_ID'",
                "selectInventory": ["model","location_lat","location_lon"],
		"searchInventory": {"model": ""},
                "selectInterfaces": ["ip","type"]
                },
        "id":'$ID',
        "auth":"'$AUTH'"
        }'
JSON=`(fun_jsonpars "$JSON")`
for string in `(fun_api "$JSON" | jq -M '.result[]' -c -S)`
do
export `(echo "$string" |  sed 's/"\|\[\|\]\|{\|}//g' | sed 's/:/=/g' | tr ',' '\n'| sed 's/.*=\(.*=.*\)/\1/g')`
#Так фильтр как по пустому значению модели не вышло через API.
[ -z "$model" ] || continue
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
MODEL=`(/usr/zabbix/Zabbix_definition_device.sh $ip/32)`

echo MODEL:$MODEL
JSON='{
        "jsonrpc":"2.0",
        "method":"host.update",
        "params":{
                "hostid":"'$hostid'",
		"inventory": {"model": "'$MODEL'"},
		"inventory_mode": 1
                },
        "id":'$ID',
        "auth":"'$AUTH'"
        }'
JSON=`(fun_jsonpars "$JSON")`
fun_api "$JSON"
echo -e "\n"
done
