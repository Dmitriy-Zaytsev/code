#!/bin/bash
#Добавляем hostname,а также координаты на хосты которые не отключены и отвечают по snmp,
#координаты будут добавленны по имени хоста если их нет.
###wget -S -O- --header "Content-Type: application/json" http://192.168.33.4/zabbix/api_jsonrpc.php --post-data='{"jsonrpc": "2.0","method": "host.get","params": {"output": ["hostid","host".....
#ID и AUTH нужно получить другим запросом.
echo "`(basename $0)` -f [-c]
-f - даже если есть данные всё равно изменить их.
-с - очистить данные.
"
ID="1987"
AUTH="119003ae6a54d5da2a56759cb5dff9ba"
IP='192.168.33.4'
API='http://'$IP'/zabbix/api_jsonrpc.php'
SNMP_COMM="\
ghbitktw
kp2x45dv8v
"

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
hostid: $hostid
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
[ "$name" = "$ip" ] && continue

#Если location_lat location_lon заполненны тогда не вносить изменения если нет ключя -f.
if [ ! "$1" = "-f" ]
 then
  [[ ! -z "$location_lat" || ! -z "$location_lon" ]] && continue
fi

unset CITY MGS LOCATION AREA
CITY=`(echo "$name" | cut -f 1 -d "-")`
MGS=`(echo "$name" | cut -f 2 -d "-" | sed 's/mgs\([[:digit:]]*\)_.*/\1/g')`
LOCATION=`(echo "$name" | cut -f 2 -d "-" | sed 's/mgs[[:digit:]]*_//g' | tr -d "p")`
#Набережные Челны,ЗЯБ,14 комплекс,8
KOM=`(echo $LOCATION | cut -f 1 -d "_")`
DOM=`(echo $LOCATION | cut -f 2 -d "_" | sed 's/^0//g')`


if [[ ! "$2" = "-c" ]]
  then
if [[ "$CITY" = "nch" ]]
 then
	CITY="Набережные Челны"
	mgs=`(echo "$MGS" | sed 's/^0//g')`
	[[ "$mgs" -ge "1" && "$mgs" -le "39" ]] && AREA="Новый город"
	[[ "$mgs" -ge "40" && "$mgs" -le "45" ]] && AREA="ЗЯБ"
	[[ "$mgs" -ge "50" && "$mgs" -le "60" ]] && AREA="ГЭС"
	[[ "$LOCATION" =~ "core" ]] && { KOM="4"; DOM="16"; AREA="Новый город" ;}
	[[ "$LOCATION" =~ "cgs" ]] && { KOM="4"; DOM="16"; AREA="Новый город" ;}
 else
    continue
fi
fi
echo "CITY:$CITY AREA:$AREA KOM:$KOM DOM:$DOM"
if [ -z "$2" ]
 then
  [[ -z "$KOM" || -z "$DOM" ]] && continue
fi
MAP=`(wget -O - "https://geocode-maps.yandex.ru/1.x/?geocode=$CITY, $AREA,комплекс $KOM, $DOM &results=1." 2>/dev/null | grep pos | sed 's/<\/pos>\|<pos>//g' | tr ' ' '\n' | sed  '/^$/d')`
LOC_LAT=`(echo "$MAP" | sed -n '2p')`
LOC_LON=`(echo "$MAP" | sed -n '1p')`

[ "$2" = "-c" ] && { unset LOC_LAT LOC_LON;}

JSON='{
        "jsonrpc":"2.0",
        "method":"host.update",
        "params":{
                "hostid":"'$hostid'",
		"inventory":{
			"location_lat": "'$LOC_LAT'",
			"location_lon": "'$LOC_LON'"
  		            }
                },
        "id":'$ID',
        "auth":"'$AUTH'"
        }'
JSON=`(fun_jsonpars "$JSON")`
echo "!!! Смена  гео данных $ip $name."
fun_api "$JSON"

echo "+++"

done
