#!/bin/bash
#Если нет интернета(проверка каждые 10 сек), но доступен роутер который поднимает PPPOE, заходим на него (expect) и reboot
#после reboot-а 50 сек будем ждать поднятия PPPOE не перезагружая его.
ip_router=${1:-"192.168.5.1"} #Если не указали аргумент первый, тогда ip=192.168.5.1 .
echo -e "\nreboot router- $ip_router\n"
echo $PATH -path
echo $PWD -pwd
echo $USER -user
echo $SHELL -shell
echo ""
while true
do
#ping 8.8.8.8 -c 4 -W 1 -s 56  - если из 4-х хот один прийдёт, тогда вернёт 0(true).
if ping $ip_router -c 1 -W 1 -s 56  && !  ping 8.8.8.8 -c 4 -W 1 -s 56 #Есть доступ к роутеру но нет к интернету.
   then  echo "REBOOT"
#          /usr/bin/beep -l 5000
#         /usr/bin/expect /usr/bin/reboot_router.exp $ip_router
        `(dirname $0)`/reboot_router.exp $ip_router #в той же директории что и сам скрипт.
#         wait #Дождаться когда все дочерние процессы порождёные родителским завершат работу, применяется если процесс дочерний был запущен в фоне.
   else echo "NO REBOOT"
fi
sleep 5 #проверять будем каждые 5 сек.
done

#!/usr/bin/expect
set timeout 1
#ip = нулевая позиция в строке аргументов, т.е. 1ый аргумент.

##SCRIPT reboot_router.exp
#spawn ssh root@[ lindex $argv 0 ]
# while 1 {expect "password:" {break}}
#send "root\n"
# while 1 {expect "#" {break}}
#send "cat /proc/uptime\n"
# expect "#"
#set uptime [ lindex $expect_out(buffer) 3 ]
# send_user "UPTIME $uptime sec\n"
# #15 сек время которое должно пройти как минимум после загрузки роутера.
#set time [expr 15 - $uptime ]
##Если 15 сек прошло
#if { $time <= 0 } {
#send "reboot\n"
#exec /bin/date "+%d/%m/%y %H:%M:%S:%N" >> /home/dima/reboot_router.txt
#} else {
#send_user "Ждём $time сек. роутер недавно загрузился.\n"
#sleep $time}
##Что бы на экране видеть что выодиться
# expect "sdfsdf"
