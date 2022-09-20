#!/usr/bin/python3
import speedtest

servers=[1907,1892]

def speed(server):
    try:
        s = speedtest.Speedtest(timeout=3,secure=False)
    except:
        print('Error Speedtest')
        return 0,0,0,"name","sponsor"
    s.get_servers(server)
    s.get_best_server()
    s.download()
    s.upload()
    res = s.results.dict()
    return res["download"], res["upload"], res["ping"], res["server"]["name"], res["server"]["sponsor"] 

"""
def main_speed(servers):
    i=0
    for server in servers:
        server=[server]
        d, u, p, n ,s = speed(server)
        print('Test #{}'.format(i+1),n,s)
        print('Download: {:.2f} Mb/s\n'.format(d / 1024 / 1024))
        print('Upload: {:.2f} Mb/s\n'.format(u / 1024 / 1024))
        print('Ping: {} ms\n'.format(p))
        print('#'*80)
    
if __name__ == '__main__':
    main_speed(servers)
"""