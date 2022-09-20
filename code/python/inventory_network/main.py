#!/usr/bin/env python3
from easysnmp import snmp_get
from easysnmp.variables import SNMPVariable
import ipaddress
from ping3 import ping
from threading import Thread
#from datetime import datetime


snmp_version=2
snmp_ro=['ghbitktw','public','private']
snmp_oid_model='.1.3.6.1.2.1.1.1.0'
snmp_oid_enter='.1.3.6.1.2.1.1.2.0'
snmp_oid_hostname='.1.3.6.1.2.1.1.5.0'

network=['172.19.0.13/32','192.168.33.0/28','192.168.33.101']
network=['127.0.0.1/32','172.18.0.0/28']
NET=[]

def fun_snmp(ip,oid):
    for com in snmp_ro:
        try:
            value=snmp_get(oid, hostname=ip, community=com, version=snmp_version,retries=0,timeout=1)
        except:
            value=SNMPVariable('')
        else:
            return value
    return 0

def mainfunc(ip):
    p='ping-'
    s='snmp-'
    if ping(dest_addr=ip,timeout=1):
        p='ping+'
    else:
        return 0
    if  fun_snmp(ip,snmp_oid_hostname):
        s='snmp+'
    print('IP:'+ip,p,s)
    print('-' * 50)
    return 1

for n in network:
    n=ipaddress.IPv4Network(n,strict=True)
    if n.num_addresses == 1 :
        n_temp=ipaddress.IPv4Address(n.broadcast_address)
        net=n_temp
        NET.append(net)
    else:
        for net in n.hosts():
            NET.append(net)

for ip in NET:
    ipstr=str(ip)
    thread1 = Thread(target=mainfunc,args=(ipstr,)) ##mainfunc(ip=ipstr)
    thread1.start()
thread1.join()
