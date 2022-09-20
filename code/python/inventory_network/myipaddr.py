#!/usr/bin/env python3
import ipaddress
NET=[]
def fun_addrrange(net):
    for st in net:
        n=st['ip']
        d=st['ipplandesc']
        n=ipaddress.IPv4Network(n,strict=False)
        if n.num_addresses == 1 :
            n_temp=ipaddress.IPv4Address(n.broadcast_address)
            net=n_temp
            l={'ip':net, 'ipplandesc':d}
            NET.append(l)
        else:
            for net in n.hosts():
                l={'ip':net, 'ipplandesc':d}
                NET.append(l)
    return NET