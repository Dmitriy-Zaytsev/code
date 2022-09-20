#!/bin/bash
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
	"jsonrpc": "2.0",
	"method": "item.get",
	"params": {
		"output": ["itemid","name","status","state","error"],
		 "filter": {
			"state": "1"
        		},
		"selectHosts": ["name","state","host","status"]
		},
	"id":"'$ID'",
	"auth":"'$AUTH'"
	}'
JSON=`(fun_jsonpars "$JSON")`
fun_api "$JSON" | jq .
