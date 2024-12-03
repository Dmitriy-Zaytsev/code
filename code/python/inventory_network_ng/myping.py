#!/usr/bin/env python3
import argparse
from ping3 import verbose_ping as ping

#ping.EXCEPTIONS = True
#ping.DEBUG = True
ip_def = '10.100.27.100'


def fun_ping(ip):
    print('The function fun_ping is read in the file myping.py')
    # try:
    try:
        ping(dest_addr=ip, timeout=1, count=3, size=128, interval=0.3)
    except Exception as e:
        print(f"Error ping exception: {e}")
        return False
    except:
        print('Error ping')
        return False
    else:
        print('Ping OK')
        return True


if __name__ == '__main__':
    print('Launch file myping.py')
    parser = argparse.ArgumentParser(description='ICMP Request script')
    parser.add_argument('--ip','-ip', type=str, default=ip_def, dest='ip',
                        help='IP address of the device (default: 10.100.27.1)')
    args = parser.parse_args()
    ip = args.ip
    fun_ping(ip)
