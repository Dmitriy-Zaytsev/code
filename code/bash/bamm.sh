#!/bin/bash
#Скрипт с expect для поднятия интерфеса на cisco 3845, для связи с железом BAMM.
key=$1

exp_add () {
ip link add link eth1 name eth1.79 type vlan id 79
ip link set eth1.79 up
ip add add 172.30.10.2/30 dev eth1.79
/usr/bin/expect -c \
'
set timeout 1
sleep 1
spawn telnet 192.168.32.4
while 1 {
send "dima.z\n"
send "pfqwtd\n"
expect "#" {break}
}
send \n\n\n
while 1 {expect "#" { send "configure termin\n";break}}
while 1 {expect "#" { send "interface gigabitEthernet 0/1.79\n";break}}
while 1 {expect "#" { send "encapsulation dot1Q 79\n";break}}
while 1 {expect "#" { send "ip vrf forwarding BAMM\n";break}}
while 1 {expect "#" { send "ip address 172.30.10.1 255.255.255.252\n";break}}
while 1 {expect "#" { send "no cdp  enable\n";break}}
while 1 {expect "#" { send "no snmp trap link-status\n";break}}
while 1 {expect "#" { send "exit\n";break}}
while 1 {expect "#" { send "exit\n";break}}
while 1 {expect "#" { send "exit\n";break}}
'
}


exp_del () {
/usr/bin/expect -c \
'
set timeout 1
sleep 1
spawn telnet 192.168.32.4
while 1 {
send "dima.z\n"
send "pfqwtd\n"
expect "#" {break}

}
send \n\n\n
while 1 {expect "#" { send "configure termin\n";break}}
while 1 {expect "#" { send "no interface gigabitEthernet 0/1.79\n";break}}
while 1 {expect "#" { send "exit\n";break}}
while 1 {expect "#" { send "exit\n";break}}
'
}


if [ "$key" = "add" ]
 then
exp_add
elif [ "$key" = "del" ]
 then
exp_del
else
echo "Нет ключа."
fi
