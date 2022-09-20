#!/usr/bin/python3
from sh import ping

def ping_fun(type_='slow',address='8.8.8.8'):
    if type_ == 'slow':
        flag='-4',address,'-c 3'
    else:
        flag='-4',address,'-c 100','-f','-Mdo','-s 1400','-q'
    try:    
        p=ping(flag)
    except:
        p='No connect internet'
    print(p)
    return p
 
"""
if __name__ == '__main__':
    ping_fun(type_='fast',address='8.8.8.8')
"""