#!/usr/bin/env python3
import ipaddress
import argparse

ip_def = '10.100.27.15/30'

# netinf=[{'ip':'172.19.0.13/30', 'netboxtag':'mysw'},{'ip':'192.168.33.1/32', 'netboxtag':'network33'}]


def fun_addrrange(netinf):
    ipinfall = []
    ipinfall.clear()
    print('The function fun_addrrange is read in the file myipaddr.py')
    for netinfstr in netinf:
        n = netinfstr['ip']
        d = netinfstr['netboxtag']
        n = ipaddress.IPv4Network(n, strict=False)
        if n.num_addresses == 1:
            ip = ipaddress.IPv4Address(n.broadcast_address)
            ipinf = {'ip': ip, 'netboxtag': d}
            ipinfall.append(ipinf)
        else:
            for ip in n.hosts():
                ipinf = {'ip': ip, 'netboxtag': d}
                ipinfall.append(ipinf)
    print('ipinfall: ' + str(ipinfall))
    return ipinfall


if __name__ == '__main__':
    print('Launch file myipaddrg.py')
    parser = argparse.ArgumentParser(description='IP layout by hosts')
    parser.add_argument('--ip', '-ip', type=str, default=ip_def, dest='ip',
                        help='IP address of the device (default: 10.100.27.10/24)')
    args = parser.parse_args()
    ip = args.ip
    if parser.parse_args().ip:
        netinf = [{'ip': ip, 'netboxtag': 'test'}]
    fun_addrrange(netinf)
