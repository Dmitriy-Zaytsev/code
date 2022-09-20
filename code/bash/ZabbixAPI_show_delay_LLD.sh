#!/bin/bash
#Быстрый обход по правилам lld и просмотр частоты/времени переопроса(пересоздание item-ов).
#Что бы просматреть/исправить lld item можно перейти на него  где $itemid=itemid созданный lld.
#http://192.168.33.4/zabbix/host_discovery.php?form=update&itemid=$itemid
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




#Получим шаблоны у которых есть хоть одино правило lld.
JSON='{
        "jsonrpc": "2.0",
        "method": "template.get",
        "params": {
                "output": ["host","templateid"],
                "selectDiscoveries": "count"
                },
        "id":"'$ID'",
        "auth":"'$AUTH'"
        }'

JSON=`(fun_jsonpars "$JSON")`

for string in `(fun_api "$JSON" | jq -M '.result[]' -c -S | sed 's/ /SPACE/g')`
 do
   #export `(echo "$string" |  sed 's/"\|\[\|\]\|{\|}//g' | sed 's/:/=/g' | tr ',' '\n'| sed 's/.*=\(.*=.*\)/\1/g')`
   export `(echo "$string" |  sed -E 's/,"|",/\n/g' | sed -E 's/\{"|\"}//g' | sed 's/"//g' | sed 's/:/=/g')`
   [ "$discoveries" = "0" ] && continue
   echo "____________________"
   export "`(echo -n host=;echo "\"$host\"" | sed 's/SPACE/ /g')`"
   echo -e "templateid: $templateid\nhost: $host\ndiscoveries: $discoveries"



   #Получим lld правила с даного шаблона и время обновления.
   JSON_2='{
        "jsonrpc": "2.0",
        "method": "discoveryrule.get",
        "params": {
                "output": ["itemid","name","key_","lifetime","delay","delay_flex","templateid"],
                "templateids": "'$templateid'",
                "selectHostPrototypes": "count"
                },
        "id":"'$ID'",
        "auth":"'$AUTH'"
        }'
   JSON_2=`(fun_jsonpars "$JSON_2")`

   for string in `(fun_api "$JSON_2" | jq -M '.result[]' -c -S | sed 's/ /SPACE/g')`
    do
      echo "$string" > /tmp/1.txt

      export `(echo "$string" | sed -E 's/,"|",/\n/g' | sed -E 's/\{"|\"}//g' | sed 's/"//g' | sed 's/:/=/g')`
      [ "$?" = "1" ] && exit
      export "`(echo -n name=;echo "\"$name\"" | sed 's/SPACE/ /g')`"
      export "`(echo -n key=;echo "\"$key\"" | sed 's/SPACE/ /g')`"
      echo "+++"
      echo -e "\titemid: $itemid\n\tname: $name\n\tkey: $key_\n\tdelay: $delay\n\tdelay_flex: $delay_flex\n\tlifetime: $lifetime"
    done


   echo "____________________"
 done
