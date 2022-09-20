#!/bin/bash
#Скрипт для удаление всех item,graph,trigger -ов полученных с помощью lld.
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

#Удаление элементов.
JSON='{
        "jsonrpc":"2.0",
        "method":"item.get",
        "params":{
                "output":["itemid","flags"],
                 "filter":{
                        "flags": "4"
                        }
                },
        "id":'$ID',
        "auth":"'$AUTH'"        }'

JSON=`(fun_jsonpars "$JSON")`
#fun_api "$JSON"
for string in `(fun_api "$JSON" | jq -M '.result[]' -c -S)`
do
export `(echo "$string" |  tr ',' '\n' | sed 's/ /_/g' | sed 's/"\|\[\|\]\|{\|}//g' | sed 's/:/=/g')`
echo "
itemid: $itemid
flags: $flags
"
echo "!!! Удаление itemid:$itemid."
JSON='{
        "jsonrpc":"2.0",
        "method":"item.delete",
        "params":[
                "'$itemid'"
                ],
        "id":'$ID',
        "auth":"'$AUTH'"        }'

JSON=`(fun_jsonpars "$JSON")`
fun_api "$JSON"
done



#Удаление графиков.
JSON='{
        "jsonrpc":"2.0",
        "method":"graph.get",
	"params":{
                "output":["graphid","flags"],
                "filter":{
                        "flags": "4"
                        }
                },
        "id":'$ID',
        "auth":"'$AUTH'"        }'

JSON=`(fun_jsonpars "$JSON")`
#fun_api "$JSON"
for string in `(fun_api "$JSON" | jq -M '.result[]' -c -S)`
do
export `(echo "$string" |  tr ',' '\n' | sed 's/ /_/g' | sed 's/"\|\[\|\]\|{\|}//g' | sed 's/:/=/g')`
echo "
itemid: $itemid
flags: $flags
"
echo "!!! Удаление graphid:$itemid."
JSON='{
        "jsonrpc":"2.0",
        "method":"graph.delete",
        "params":[
                "'$graphid'"
                ],
        "id":'$ID',
        "auth":"'$AUTH'"        }'

JSON=`(fun_jsonpars "$JSON")`
fun_api "$JSON"
done


#Удаление тригерров.
JSON='{
        "jsonrpc":"2.0",
        "method":"trigger.get",
        "params":{
                "output":["triggerid","flags"],
		"filter":{
                        "flags": "4"
                        }
                },
        "id":'$ID',
        "auth":"'$AUTH'"        }'

JSON=`(fun_jsonpars "$JSON")`
#fun_api "$JSON"
for string in `(fun_api "$JSON" | jq -M '.result[]' -c -S)`
do
export `(echo "$string" |  tr ',' '\n' | sed 's/ /_/g' | sed 's/"\|\[\|\]\|{\|}//g' | sed 's/:/=/g')`
echo "
triggerid: $triggerid
flags: $flags
"
echo "!!! Удаление triggerid:$triggerid."
JSON='{
        "jsonrpc":"2.0",
        "method":"trigger.delete",
        "params":[
                "'$triggerid'"
                ],
        "id":'$ID',
        "auth":"'$AUTH'"        }'

JSON=`(fun_jsonpars "$JSON")`
fun_api "$JSON"
done
