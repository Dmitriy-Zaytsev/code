#!/usr/bin/env python3
# %reset -f
# from config_inventory import *

import sys
sys.dont_write_bytecode = True
import os
import re
import argparse
from threading import Thread
import importlib


sys.path.append('/root/bin/')
import mypostgresql
import mymodelclass
import mysnmp
import mynmap
import myipaddr
import mynetbox


importlib.reload(mymodelclass)

os.system('ulimit -n 1000000')




ip = ''
ip_def = '10.100.27.10/32'
# netinf=[{'ip':'172.19.0.13/32', 'netboxtag':'mysw'},{'ip':'192.168.33.0/24', 'netboxtag':'network33'}]
# netinf=[{'ip':'172.19.0.13', 'netboxtag':'mysw'}]


oid_model_cisco=['.1.3.6.1.2.1.47.1.1.1.1.13.1', '.1.3.6.1.2.1.1.1.0' ,'.1.3.6.1.2.1.47.1.1.1.1.13.1001', 'iso.3.6.1.2.1.47.1.1.1.1.13.24555730']
oid_model_huawei=['.1.3.6.1.2.1.1.1.0.9.9.9.9.9']
oid_sysdescr='.1.3.6.1.2.1.1.1.0'


def fun_start(ip, netboxtag):
    print('The function fun_start is read in the file network_discovery.py')
    snmp_r = ''
    snmp_v = ''
    model = ''
    ping = False
    snmp = False
    ssh = False
    telnet = False
    
    if mynmap.fun_ping(ip) == False:
        print('Error ping: '+ip)
        # mypostgresql.fun_error(ip)
        return 10
    ping = True
    
    model, snmp_r, snmp_v = mysnmp.fun_snmp(ip, oid=oid_sysdescr)
    if snmp_r != '' and snmp_v != '': snmp = True
     
    def fun_clear_model(model):
        model = model.replace('\r', ' ').replace('\n', ' ')
        model = re.sub("[^a-zA-Z0-9/,.-[] _()]", "", model)[0:180]
        return ''.join(filter(str.isprintable, model))
    model = fun_clear_model(model)
    
    print('\t\t\t clear value model answer:'+str(model))
    
    # if re.search('Huawei', model, re.IGNORECASE):
    #     for oid in oid_model_huawei:
    #         try:
    #             model, snmp_r, snmp_v = mysnmp.fun_snmp(ip, oid=oid, snmp_r=[snmp_r], snmp_v=[snmp_v])
    #         except Exception as e:
    #             print(f'\t\t\t Except: {e}')
    #         else:
    #             if not re.search('NOSUCHINSTANCE', model, re.IGNORECASE) and \
    #                not re.search('NOSUCHOBJECT', model, re.IGNORECASE) and \
    #                 model != None and model != '':
    #                     break

    # if re.search('[cC]isco', model):
    #     for oid in oid_model_cisco:
    #         try:
    #             model, snmp_r, snmp_v = mysnmp.fun_snmp(ip, oid=oid, snmp_r=[snmp_r], snmp_v=[snmp_v])
    #         except Exception as e:
    #             print(f'\t\t\t Except: {e}')
    #         else:
    #             if not re.search('NOSUCHINSTANCE', model, re.IGNORECASE) and \
    #                not re.search('NOSUCHOBJECT', model, re.IGNORECASE) and \
    #                 model != None and model != '':
    #                     break

    if model == None: print('\t\t\t model: None '+model) ;return 20
    if model == '': print('\t\t\t model: Null '+model); return 30
    if re.search('NOSUCHINSTANCE', model, re.IGNORECASE): print('\t\t\t model: '+model); return 40
    if re.search('NOSUCHOBJECT', model, re.IGNORECASE): print('\t\t\t model: '+model); return 50


    # Huawei
    if re.search('S6735S-S48X6C-A', model):
        try:
            device = mymodelclass.Huawei_S6735S_S48X6C_A(ip, snmp_r, snmp_v, netboxtag=netboxtag)
        except Exception as e:
            device = mymodelclass.Model(ip, snmp_r, snmp_v, model=model, netboxtag=netboxtag)
            print(f'\t\t\t except: {e}')
    if re.search('S5731-H48P4XC ', model):
        try:
                device = mymodelclass.Huawei_S5731_H48P4XC(ip, snmp_r, snmp_v, netboxtag=netboxtag)
        except Exception as e:
                device = mymodelclass.Model(ip, snmp_r, snmp_v, model=model, netboxtag=netboxtag)
                print(f'\t\t\t except: {e}')
    if re.search('S5731-S48P4X ', model):
        try:
                    device = mymodelclass.Huawei_S5731_S48P4X(ip, snmp_r, snmp_v, netboxtag=netboxtag)
        except Exception as e:
                    device = mymodelclass.Model(ip, snmp_r, snmp_v, model=model, netboxtag=netboxtag)
                    print(f'\t\t\t except: {e}')
    if re.search('S5731-S24T4X ', model):
        try:
            device = mymodelclass.Huawei_S5731_S24T4X(ip, snmp_r, snmp_v, netboxtag=netboxtag)
        except Exception as e:
            device = mymodelclass.Model(ip, snmp_r, snmp_v, model=model, netboxtag=netboxtag)
            print(f'\t\t\t except: {e}')
    if re.search('S5735', model):
        try:
            device = mymodelclass.Huawei_S5735(ip, snmp_r, snmp_v, netboxtag=netboxtag)
        except Exception as e:
            device = mymodelclass.Model(ip, snmp_r, snmp_v, model=model, netboxtag=netboxtag)
            print(f'\t\t\t except: {e}')

    try:
        print('device: '+str(device))
    except:
        device = mymodelclass.Model(ip, snmp_r, snmp_v, model=model, netboxtag=netboxtag)
        print('device: '+str(device))
              
    data = [device.ip, device.name, device.vendor, device.model, device.type,
        device.firmware, device.netboxtag, device.ifdescr,device.physaddress]

    print('\t\t\t insert sql data: '+str(data))
    mypostgresql.fun_insert(data)
    
    #debug data
    #with open('output.txt', 'a') as f: f.write(str(data))
    with open('output.txt', 'a') as f: f.write(str(device.ip+'\n'))



if __name__ == '__main__':
    #sys.argv = ['sys.argv[0]','-ip','10.100.27.12/32']
    sys.argv = ['sys.argv[0]', '--config','-config']
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--ip', '-ip', type=str, dest='ip',
                        default=ip_def, help='INPUT ipaddress')
    parser.add_argument('--config', '-config', action='store_true',
                        default=False, help='List(netinf) ip via config.ini')
    
    if parser.parse_args().ip and not parser.parse_args().config:
        netinf = [{'ip': parser.parse_args().ip, 'netboxtag': 'netboxtag'}]
    else:        
        netinf = mynetbox.fun_get_pref()
 




#debug data
with open('output.txt', 'w') as f: f.writelines('')


ipinfall = myipaddr.fun_addrrange(netinf)

for ipinfstr in ipinfall:
    print('Launch file network_discovery.py')
    print('ipinfstr: '+str(ipinfstr))
    try:
        ip = str(ipinfstr['ip'])
    except:
        continue
    try:
        netboxtag = str(ipinfstr['netboxtag'])
    except:
        netboxtag = 'netboxtag'

    fun_start(ip, netboxtag)
#THREAD
#    thread1 = Thread(target=fun_start,args=(ip,netboxtag))
#    threads = []
#    threads.append(thread1)
#    thread1.start()

# for thread1 in threads:
#     thread1.join()

mypostgresql.fun_delete()
mypostgresql.fun_close()

#debug data
with open('output.txt', 'r') as f: content = f.read(); print(content)
