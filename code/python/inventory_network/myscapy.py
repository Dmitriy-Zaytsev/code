#!/usr/bin/env python3
from scapy.all import *

def fun_showpacket(p):
    p.show2()

pkg=sniff(iface='enp2s0.69',count=5,timeout=10,filter='tcp',prn=fun_showpacket)