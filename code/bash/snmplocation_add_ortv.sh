#!/bin/bash
#Добавляем по snmpset snmplocale из файла.
file=/tmp/OUTV.txt
echo <<EOF
cat /tmp/OUTV.txt
SDO3002|MGS16_62/06-2p|SDO3002_MGS16_62/06-1p|10.223.214.199
SDO3002|MGS34_37/01-4p|SDO3002_MGS34_37/01-4p|10.223.216.194
OU_LambdaPro72|MGS09_ou-27/15-1|MGS09_ou-27/15-1|10.223.218.25
LambdaPRO72|MGS15_59/16/2-1p|LambdaPRO72_MGS15_59/16/2-1p|10.223.214.166
SDO3002|MGS15_58/12-8p|SDO3002_MGS15_58/12-8p|10.223.214.167
SDO3002|MGS15_59/20-1p|SDO3002_MGS15_59/20-1p|10.223.214.168
LambdaPRO72|MGS10_ou-26/04-22|LambdaPRO72_MGS10_ou-26/04-22|10.223.218.26
EOF

ipdb=192.168.33.2
portdb=22
ipmy=192.168.33.13
portmy=44
db=ipplan
userdb=ipplan
passworddb=ipplan
rocommunity=ghbitktw


echo "Получение данных с DB $db в файл $file"
rm $file -f
echo "SELECT userinf,location,descrip,inet_ntoa(ipaddr) FROM ipaddr WHERE userinf LIKE '%LambdaPRO72%' OR userinf LIKE '%SDO3002%' OR userinf LIKE '%TUZ%';"\
 | ssh dima@$ipdb -p $portdb "mysql --host=localhost --user=$userdb --password=$passworddb $db" \
 | tr '\t' '|'  | sed 's/ /_/g' > $file

[ -s $file ] || { echo "Данные не получены.";exit 1;}
echo "Данные получены."


while read string
do
locale=`(echo $string | cut -d "|" -f 2)`
ip=`(echo $string | cut -d "|" -f 4)`
ping -c 1 $ip &>/dev/null || { echo "Не доступен $ip";continue;}
localebefore=`(snmpget -v 1 -c $rocommunity $ip SNMPv2-MIB::sysLocation.0 -Onqv 2>/dev/null)`
[ "$localebefore" = "$locale" ] && { echo "Изменение $ip snmp locale не требуется.";continue;}
model=`(snmpget -v1 -c $rocommunity $ip SNMPv2-MIB::sysDescr.0 -t 1 -r 1 -Onqv 2>/dev/null)`
model=${model:-model}
rwcommunity=private
[ "$model" = "sdo3002" ] && rwcommunity=`(snmpget -v 1 -c $rocommunity $ip SNMPv2-SMI::enterprises.32108.1.7.4.2.3.0 -Onqv 2>/dev/null | tr -d '"')`
echo IP:$ip LOCALE:$locale MODEL:$model RWCOMMUNITY:$rwcommunity
snmpset -v 1 -c $rwcommunity $ip SNMPv2-MIB::sysLocation.0 s $locale &>/dev/null
localeafter=`(snmpget -v 1 -c $rocommunity $ip SNMPv2-MIB::sysLocation.0 -Onqv 2>/dev/null)`
echo "$localebefore --> $localeafter"
echo ---
done <$file

