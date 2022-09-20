#!/bin/bash
#Проверяем соответствие inventory model и главным шаблонам (условие главного шаблона grep -E "^([[:alnum:]]|-|\.)*_([[:alnum:]]|-|\.)*$" и  "$templates" -le "1")
ID="1987"
AUTH="119003ae6a54d5da2a56759cb5dff9ba"
IP='192.168.33.4'
API='http://'$IP'/zabbix/api_jsonrpc.php'

file_template="/tmp/`(basename $0)`_template.txt"
file_host="/tmp/`(basename $0)`_host.txt"
> "$file_template"
> "$file_host"
#На какую группу узлов будет примененно, 9=DEVICE
GROUP_ID="9"

fun_jsonpars () {
echo $1 | tr -d '\n' | tr -d ' ' | tr -d '\t'
}

fun_api () {
REQUEST=$1
HEADER='--header Content-Type:application/json'
POSTDATA='--post-data='$REQUEST''
wget -S -O- $HEADER $API $POSTDATA 2>/dev/null
}


fun_link () {

JSON='{
        "jsonrpc":"2.0",
        "method":"host.update",
        "params":{
                "hostid": "'$id_host'",
                "templates": [{"templateid": "'$id_temp'"}],
		"inventory_mode": 1
                },
        "id":'$ID',
        "auth":"'$AUTH'"
        }'
JSON=`(fun_jsonpars "$JSON")`
fun_api "$JSON"
}


fun_unlink () {

JSON='{
        "jsonrpc":"2.0",
        "method":"host.update",
        "params":{
                "hostid": "'$id_host'",
                 "templates_clear": [{"templateid": "'$id_temp'"}],
		"inventory_mode": 1
                },
        "id":'$ID',
        "auth":"'$AUTH'"
        }'
JSON=`(fun_jsonpars "$JSON")`
fun_api "$JSON"
}




JSON='{
	"jsonrpc": "2.0",
	"method": "template.get",
    	"params": {
	"output": ["name","templateid"],
	"selectTemplates": true,
        "selectHosts": true
	},
	"auth": "'$AUTH'",
	"id": '$ID'
        }'
JSON=`(fun_jsonpars "$JSON")`
echo "Вывод главных шаблонов:"
for string in $(fun_api "$JSON" | sed 's/ /[]/g' | jq -M '.result[]' -c -S)
    do
	string=`(echo "$string" | sed 's/\[\]/ /g')`
	export `(echo "$string" |sed 's/,/\n/g' | sed 's/"\|}\|{//g' | sed 's/:/=/g')`
#Если не 0 значит шаблон не содержиться в другом шаблоне, а нам нужны главные которые состоят$
#Или 1 допустим есть шаблон  Edge-Core_ECS3510-28T который включён в Edge-Core_ECS3510-52T.
	if [[ ! "$templates" -le "1" ]]
  	    then
    		continue
	fi
	echo "$name" | grep -E "^([[:alnum:]]|-|\.)*_([[:alnum:]]|-|\.)*$" &>/dev/null || continue
	#echo "$name;$templateid;$templates;$hosts" | tee -a "$file_template"
	echo "$name;$templateid" | tee -a "$file_template"
done


#type=2 значит есть snmp interface.
JSON='{
        "jsonrpc": "2.0",
        "method": "host.get",
        "params": {
	"output": ["hostid","name"],
	"filter": {"type": "2"},
        "groupids": "'$GROUP_ID'",
	"selectInventory": ["model"],
        "withInventory": true,
	"selectParentTemplates": [
            "templateid"
        ]
        },
        "auth": "'$AUTH'",
        "id": '$ID'
        }'

JSON=`(fun_jsonpars "$JSON")`
echo "Вывод хостов:"
for string in $(fun_api "$JSON" | sed 's/ /[]/g' | jq -M '.result[]' -c -S)
    do
        string=`(echo "$string" | sed 's/\[\]/ /g')`
	export `(echo "$string" | sed 's/":"/=/g' |  sed 's/"\|}\|{\|"\|://g' | sed 's/,templateid=/:/g' | sed 's/parentTemplates\|\[\|\]//g' | sed 's/,/\n/g')`
	[ -z "$model" ] && continue
	echo "$hostid;$name;$model;$templateid" | tee -a "$file_host"
done

echo "Проверка соответствия inventory model и присоединённого шаблона к хосту:"
for string in `(cat "$file_template")`
    do
	name_temp=`(echo "$string" | cut -d ";" -f 1)`
	echo "Присоединение шаблона $name_temp ..."
	id_temp=`(echo "$string" | cut -d ";" -f 2)`
	for string in `(cat "$file_host" | grep ";$name_temp;")`
	    do
		id_host=`(echo "$string" | cut -d ";" -f 1)`
		name_host=`(echo "$string" | cut -d ";" -f 2)`
		if echo "$string" | sed 's/:\|;/\n/g' | grep "^$id_temp$" &>/dev/null
		   then
			echo "Шаблон $name_temp уже присоеденён к $name_host."
		   else
			echo "Присоединение шаблона $name_temp к $name_host."
			fun_link
			echo "\n"
		fi
	    done

    done


for string in `(cat "$file_template")`
    do
	#echo "STRING_TEMPL:"$string""
        name_temp=`(echo "$string" | cut -d ";" -f 1)`
	echo "Остсоединение шаблона $name_temp ..."
        id_temp=`(echo "$string" | cut -d ";" -f 2)`
        for string in `(cat "$file_host" | grep -v ";$name_temp;")`
            do
		id_host=`(echo "$string" | cut -d ";" -f 1)`
                name_host=`(echo "$string" | cut -d ";" -f 2)`
                if echo "$string" | sed 's/:\|;/\n/g' | grep "^$id_temp$" &>/dev/null
                   then
			#echo "STRING_HOST:"$string" ID_TEMP:"$id_temp""
			#echo "$string" | sed 's/:\|;/\n/g' | grep "^$id_temp$"
                        echo "Отсоединение шаблона $name_temp от $name_host."
			fun_unlink
			echo -e "\n"
                fi
            done

    done
