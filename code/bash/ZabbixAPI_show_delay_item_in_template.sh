#!/bin/bash
#Просмотр частоты опроса всех item-ов в шаблонах так же портатипов item-ов(lld).
#Что бы просматреть/исправить item можно перейти на него где $itemid=itemid созданный статикой или lld.
#http://192.168.33.4/zabbix/items.php?form=update&itemid=$itemid
#Что бы исправить/посмотреть шаблон
#http://192.168.33.4/zabbix/templates.php?form=update&templateid=$templateid

#Для lld портотипов, правило дискавери
#http://192.168.33.4/zabbix/host_discovery.php?form=update&itemid=$itemid_1
#В каком шаблоне правило дискавери
#http://192.168.33.4/zabbix/templates.php?form=update&templateid=$templateid
#Сам item
#http://192.168.33.4/zabbix/disc_prototypes.php?form=update&itemid=$itemid_2&parent_discoveryid=$itemid_1


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

fun_item () {
JSON='{
        "jsonrpc": "2.0",
        "method": "template.get",
        "params": {
                "output": ["host","templateid"],
		"selectItems": ["name","itemid","delay","delay_flex","history","trends"]
                },
        "id":"'$ID'",
        "auth":"'$AUTH'"
        }'

JSON=`(fun_jsonpars "$JSON")`

fun_api "$JSON" | jq '.result[]'
}

fun_item_prototype () {
JSON='{
        "jsonrpc": "2.0",
        "method": "discoveryrule.get",
        "params": {
		"output": ["itemid","name","hostid","templateid"],
		"selectItems": ["name","itemid","delay","delay_flex","history","trends"]
                },
        "id":"'$ID'",
        "auth":"'$AUTH'"
        }'

JSON=`(fun_jsonpars "$JSON")`

fun_api "$JSON" | jq '.result[]'
}

fun_item
fun_item_prototype
