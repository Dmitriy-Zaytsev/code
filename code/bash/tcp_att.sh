#!/bin/bash
ip_src="172.19.12.13"
port_src=;
ip_dst="172.19.12.152"
port_dst='33'

! dpkg-query -s python-scapy  &>/dev/null &&  { echo "Не установлен python-scapy."; exit 1;}


iptables -A OUTPUT -t filter -p tcp -d $ip_dst -s $ip_src --dport $port_dst --tcp-flags RST RST -j DROP

for port_src in `(seq 50000 60000)`
do
echo -e "\n\n$port_src\n\n"
python - &>/dev/null <<EOF
from scapy.all import *
import sys
ip=IP(src="$ip_src",dst="$ip_dst")
tcp_syn=TCP(sport=$port_src,dport=$port_dst,flags="S",seq=3810181411)
pdu=ip/tcp_syn
recived_synack=sr1(pdu)
my_ack=recived_synack.seq+1
tcp_ack=TCP(sport=$port_src,dport=$port_dst,flags="A",seq=3810181412,ack=my_ack)
send(ip/tcp_ack)
EOF
done
