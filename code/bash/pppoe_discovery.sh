#!/bin/bash


fun_python () {
python - <<EOF
from scapy.all import *
import threading
from time import sleep
l2=Ether(src="00:50:ba:85:53:43",dst="ff:ff:ff:ff:ff:ff",type=0x8100)
vlan=Dot1Q(vlan=415,type=0x8863)
PPPoE_discovery=PPPoED(version=1,type=1,code=9,sessionid=0,len=4)
RAW=Raw(load='\x01\x01\x00\x00')
pdu=l2/vlan/PPPoE_discovery/RAW
sendp(pdu,iface='eth1',count=1,inter=0.1)
EOF
}

fun_python
