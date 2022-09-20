#!/usr/bin/env python3
from ping3 import ping
def fun_ping(ip):
    try:
        if ping(dest_addr=ip,timeout=10):
            print('.');
            return True
        else:
            return False
    except:
        return False