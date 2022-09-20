#!/bin/bash
#Перенаправляем вывод другой программы на ввод скрипту.
var=$(</dev/stdin)
[ -z "$var" ] && echo "Нет вывода на ввод." && exit
echo $var | sed 's/\ /^/g' | tr '\r\n' ' ' | sed 's/\.\.\.\.\.\./\n/g' | awk '{print $2" "$3" "$1" "$4}' | sed '/^ /d' | sort -h -k 1

#cat ./sw_device.txt
#...
##......
##172.19.5.63
##DGS-1100-08
##r3-2/18-16sw1
##78:54:2e:20:90:56
##......
#...
#
#cat ./sw_device.txt | ./stdout_in_script.sh
#...
##DGS-1100-08 r3-6/01-16sw1 172.19.7.250 d8:fe:e3:40:fe:f
##DGS-1100-08 r3-6/01-16sw2 172.19.7.251 78:54:2e:20:8f:8a
##DGS-1100-08 r3-6/01-15sw1 172.19.7.252 d8:fe:e3:40:fe:95
##DGS-1100-08 r3-6/01-15sw2 172.19.7.253 d8:fe:e3:40:fe:92
#...