#!/bin/bash
#Добавляем по snmpset snmplocale из файла.
packages='
nmap
libreoffice-common
'

for pack in $packages
 do
  dpkg-query -s $pack &>/dev/null || { echo "Не установлен пакет $pack" && exit 3;}
 done


file_in=/tmp/ip.txt
file_out=/tmp/ip_location_ping_snmp_telnet.csv

user=dima
ipdb=192.168.33.2
portdb=22
ipmy=192.168.33.13
portmy=44
db=ipplan
userdb=ipplan
passworddb=ipplan

rocommunity=ghbitktw

echo "Для того что бы не вводить при ssh соединении password,
нужно организовать аутентификацию по ключу на PC $ipdb.

PC $ipdb:
sed 's/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g'
 /etc/init.d/sshd restart

PC localhost:
echo $USER
dima
ssh-copy-id -i ~/.ssh/id_rsa.pub $user@$ipdb

FILE_IN=$file_in
FILE_OUT=$file_out
"

read

rm -rf $file_out
stringnum=`(wc -l $file_in | cut -f 1 -d " ")`
num=0


echo "ip;location;device;ping;snmp;telnet" > $file_out
while read ipsw
 do
((num=num+1))
((progress=$num*100/$stringnum))
tput setaf 3
tput el
echo -en $ipsw
tput setaf 2
tput hpa $((`(tput cols)`-5))
echo -en "$progress"%
tput setaf 7
tput hpa 0

pingvar=0
snmpvar=0
telnetvar=0
#Получение колонки location с ip плана(mysql).
 location=`(echo "SELECT  userinf,location,descrip  FROM ipaddr WHERE inet_ntoa(ipaddr)='$ipsw';"\
 | ssh $user@$ipdb -p $portdb "mysql --skip-column-names --host=localhost --user=$userdb --password=$passworddb $db" \
 | tr '\t' '|'  | sed 's/ /_/g' |  cut -f 2 -d "|")`
#Проверка доступности.
ping -c 1 -W 1 $ipsw &>/dev/null && pingvar=1
device=`(snmpget -v1 -c $rocommunity $ipsw .1.3.6.1.2.1.1.1.0 -t 1 -r 1 -Onqv 2>/dev/null)` && snmpvar=1
nmap -n -p 23 $ipsw -Pn | grep -i '23.*open' &>/dev/null && telnetvar=1
#echo IP:$ipsw LOCATION:$location DEVICE:$device PING:$pingvar SNMP:$snmpvar TELNET:$telnetvar
echo "$ipsw;$location;$device;$pingvar;$snmpvar;$telnetvar" >> $file_out
done < $file_in

echo "Конвертируем файл в xls. Возможно потребуються прова SU."
sed 's/;/,/g' $file_out -i
soffice --headless --convert-to xls $file_out --outdir /tmp
sed 's/,/;/g' $file_out -i
