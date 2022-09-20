#!/bin/bash
#ip=${1:-172.19.7.39}
username=dima.z
password=pfqwtd
fileip=/home/dima/ip2.txt
#> $fileip.log
echo `(date "+%d/%m/%y %H:%M:%S:%N")` > $fileip.log

echo START
#Пока выполняется (возвращает 0) read с параметром ip (read var -всё что мы введём запишется в переменную var),
#а ввод будет считыватся с файла (< /home/dima/ip.txt)
while read ip
do
#Если бы -с '' а не -c " ", тогда переменные с баша были не доступны, но и синтаксис в экспекте был бы как обычно.
#/usr/bin/expect -d -c \ #debug mode.
ping $ip -W 1 -c 1 &>/dev/null || { echo "$ip - Not Available." | tee -a $fileip.log && sleep 2 && continue;}
/usr/bin/expect -c \
"
set timeout 1
send_user \n\n$ip\n
sleep 1
spawn /usr/bin/telnet $ip
set var_expect 1
send_user \$var_expect
while 1 {
expect Username  {send "$username"\n }
expect Password {send "$password"\n }
expect :5 {break}
}
send \n\n\n
#while 1 {expect :5 { send create\ trusted_host\ network\ 192.168.229.4/255.255.255.255\n ; break}}
#while 1 {expect :5 { send create\ trusted_host\ network\ 192.168.229.5/255.255.255.255\n ; break}}
#while 1 {expect :5 { send config\ traffic\ control\ 1-24\ unicast\ disable\n ; break}}
while 1 {expect :5 { send config\ loopdetect\ lbd_recover_time\ 0\n; break}}
while 1 {expect :5 { send config\ loopdetect\ interval_time\ 5\n; break}}
while 1 {expect :5 { send config\ ports\ 1-24\ state\ enable\n; break}}
while 1 {expect :5 { send config\ loopdetect\ ports\ 1-24\ state\ enable\n; break}}
while 1 {expect :5 { send save\n ; break}}
while 1 {expect :5 { send logout\n ; break}}
expect "sdfsdf"
"
done  < $fileip
#OR
#done <<LIST
#172.19.3.110
#172.19.1.225
#LIST
echo EXIT
