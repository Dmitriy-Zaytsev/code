#!/bin/bash
#Просмотр всех созданных item-ов на хостах.
#Что бы просматреть/исправить item можно перейти на него где $itemid=itemid созданный статикой или lld.
#http://192.168.33.4/zabbix/items.php?form=update&itemid=$itemid
#Условие при котором item покажеться если delay_flex будет пустым и delay будет меньше...(DELAY) секунд.
DELAY=5
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
                "output": ["itemid","name","delay","delay_flex","templateid"],
		"selectDiscoveryRule": ["parent_itemid"]
                },
        "id":"'$ID'",
        "auth":"'$AUTH'"
        }'

JSON=`(fun_jsonpars "$JSON")`

for string in `(fun_api "$JSON" | jq -M '.result[]' -c -S | sed 's/ /SPACE/g')`
 do
   export `(echo "$string" |  sed -E 's/,"|",/\n/g' | sed -E 's/\{"|\"}//g' | sed 's/"//g' | sed 's/:/=/g')`
   { [ "$delay" -le "$DELAY" ] && [ -z "$delay_flex" ];} || continue
   echo "____________________"
   export "`(echo -n name=;echo "\"$name\"" | sed 's/SPACE/ /g')`"
   echo -e "\titemid: $itemid\n\tname: $name\n\tdelay: $delay\n\tdelay_flex: $delay_flex\n\ttemplateid: $templateid"
 done
