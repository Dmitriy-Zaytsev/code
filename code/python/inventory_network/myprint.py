#!/usr/bin/env python3
file='/tmp/device.csv'
file_lock='/tmp/device.csv.lock'
import os
from random import randrange
#os.remove(file)
from time import sleep
try:
    os.remove(file_lock)
except:
    #print('File not found',file_lock)
    pass
f=open(file,'w')
f.close()
def fun_print(device):
    for i in device.snmp_r:device.snmp_r=str(i)
    for i in device.snmp_v:device.snmp_v=str(i)
    """
    print('IP:',device.ip,
          '\n\tVENDOR:',device.vendor,
          '\n\tMODEL:',device.model,
          '\n\tNAME:',device.name,
          '\n\tOID_ENT:',device.oid_ent_tree,
          '\n\tFIRMWARE:',device.firmware,
          '\n\tSNMP_RO:',device.snmp_r,
          '\n\tSNMP_VERS:',device.snmp_v,)
    """
    string=device.ip+';'+device.vendor+';'+device.model+';'+device.name+';'+device.oid_ent_tree+';'+device.firmware+';'+device.snmp_r+';'+device.snmp_v
    r=randrange(1,10)
    r=r*0.1
    while os.path.exists(file_lock):
        print('sleep:',r,device.ip)
        sleep(r)
    open(file_lock, 'a').close()
    f=open(file,'a')
    f.write(string)
    f.write('\n')
    f.close()
    os.remove(file_lock)