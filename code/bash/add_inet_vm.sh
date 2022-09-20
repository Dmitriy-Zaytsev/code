#!/bin/bash -x
#Пускаем VM в инет через себя.
vm_ip="10.10.255.6"
v_int_in="vmbr2" #Интерфейс к которому подключена ВМ.
v_int_out="vmbr0" #Из которго дойдёт до hw_ip.
vserver_ip="192.168.33.89"
hw_ip="192.168.33.13"
h_int_out="eth1.69" #Интерфейс на hw,SNAT.
ITA="iptables -A"
ITD="iptables -D"
IT=;
gw_ip="192.168.33.1"

[ "$1" = "add" ] && { IT="$ITA"; gw_ip="$hw_ip";}
[ "$1" = "del" ] && { IT="$ITD";}
[ -z "$IT" ] && exit 0


   ssh root@"$vserver_ip" ""$IT" FORWARD -t filter -s "$vm_ip"/32 -i "$v_int_in" -j ACCEPT; \
"$IT" FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT; \
"$IT" POSTROUTING -t nat -s "$vm_ip"/32 -o "$v_int_out" -j SNAT --to-source "$vserver_ip"; \
ip route change 0.0.0.0/0 via "$gw_ip""

####echo ""$IT" FORWARD -t filter -m state --state RELATED,ESTABLISHED -j ACCEPT" | /bin/bash -
echo ""$IT" FORWARD -t filter -s "$vserver_ip"/32 -j ACCEPT" | /bin/bash -
echo ""$IT" POSTROUTING -t nat -s "$vserver_ip"/32 -o "$h_int_out" -j MASQUERADE" | /bin/bash -
