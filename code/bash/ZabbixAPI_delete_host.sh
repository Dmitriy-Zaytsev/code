#!/bin/bash
MODEL=$1
[[ -z "$MODEL" ]] && { echo "Не определенны переменные.";exit 2;}

ID="1987"
AUTH="119003ae6a54d5da2a56759cb5dff9ba"
IP='192.168.33.4'
API='http://'$IP'/zabbix/api_jsonrpc.php'

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
		"output":["name"],
		"selectInterfaces":["ip"],
		"selectInventory": ["model"]
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
model: $model
name: $name
"
[ ! "$MODEL" = "$model" ] && continue

echo "$ip $name $model $status."

JSON='{
        "jsonrpc":"2.0",
        "method":"host.delete",
        "params":[
		"'$hostid'"
                ],
        "id":'$ID',
        "auth":"'$AUTH'"
        }'
JSON=`(fun_jsonpars "$JSON")`
fun_api "$JSON"
done
