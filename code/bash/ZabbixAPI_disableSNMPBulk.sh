#!/bin/bash
ID="1987"
AUTH="119003ae6a54d5da2a56759cb5dff9ba"
IP='192.168.33.4'
API='http://'$IP'/zabbix/api_jsonrpc.php'
#MODEL="
#Cisco_WS-C2950T-24
#Edge-Core_ES4626-SFP
#Edge-Core_ES3528M
#Edge-Core_ES3552M
#Edge-Core_ECS3510-28T
#Edge-Core_ECS3510-52T
#Cisco_WS-C4500X-16
#Cisco_WS-C3750G-24T-S
#Cisco_ME-3600X-24FS-M
#WS-C2960G-24TC-L
#DLink_DGS1100-08
#Vector_Lambda-PRO-72
#"

MODEL="Edge-Core_ES4626-SFP
Edge-Core_ES3528M
Edge-Core_ES3552M
Cisco_WS-C2950T-24
Vector_Lambda-PRO-72"

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
		"selectInventory":["model"],
		"selectInterfaces":["ip","type","bulk","interfaceid"]
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
bulk: $bulk
interfaceid: $interfaceid
model: $model
name: $name
snmp_available: $snmp_available
status: $status
model: $model
"
[ ! "$type" = "2" ] && continue
bul=1
for mod in $MODEL
 do
	[ "$mod" = "$model" ] && { bul=0; break;}
 done

JSON='{
        "jsonrpc":"2.0",
        "method":"hostinterface.update",
        "params":{
                "interfaceid":"'$interfaceid'",
		"bulk": "'$bul'"
                 },
        "id":'$ID',
        "auth":"'$AUTH'"
        }'
JSON=`(fun_jsonpars "$JSON")`
fun_api "$JSON"
done
