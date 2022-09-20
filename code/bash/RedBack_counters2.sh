#!/bin/bash
if [ "$1" = "-p" ]
 then
	packet=$2
	cat /tmp/RedBack_counters.txt | grep $2 | sed 's/.*://g'
exit
fi

dpkg-query -s expect || { echo "Не установлен expect." && exit 1;}
ip=192.168.33.91
username=$1
password=$2

/usr/bin/expect -c \
"
set timeout 1
send_user \n\n$ip\n
sleep 1
spawn /usr/bin/telnet $ip
set var_expect 1
while 1 {
expect login  {send "$username"\n }
expect Password {send "$password"\n }
expect \# {break}
}
send show\ pppoe\ counters\n
expect sdfsdf" | tee  /tmp/RedBack_counters.txt
