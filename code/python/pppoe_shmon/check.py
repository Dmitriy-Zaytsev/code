#!/usr/bin/python3
from sh import ip
wifi_in='wlp3s0'
ether_in='enp2s0'

def check_pppoe():
    a=str(ip('link','show',ether_in))
    if ',UP' not in a:
        print('yes')
        return('Interface '+ether_in+' admin down')
    else:
        return 0


def check_speedtest():
    try:
        a=str(ip('route','get','8.8.8.8'))
    except:
        a='No connect internet!!!'
    if wifi_in in a:
        print('yes')
        return('Speedtest only via ethernet')
    else:
        return 0
    
