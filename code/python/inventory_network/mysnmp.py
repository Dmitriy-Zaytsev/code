#!/usr/bin/env python3
#import pdb;pdb.set_trace()
from easysnmp import snmp_get
from easysnmp.variables import SNMPVariable

snmp_ro=['noC2mae8Dee3','kp2x45dv8v','ghbitktw','xaxbkfi8yp0vuos']
snmp_oid_hostname='.1.3.6.1.2.1.1.5.0'
snmp_version=[2,1]

def fun_snmp(ip,oid=snmp_oid_hostname,snmp_v=snmp_version,snmp_r=snmp_ro):
    value=SNMPVariable('')
    for ver in snmp_v:
        for com in snmp_r:
            #print(ip,ver,com,oid)
            try:
                value=snmp_get(oid, hostname=ip, community=com, version=ver,retries=0,timeout=1)
            except:
                value=SNMPVariable('')
            else:
                return (value.value,com,ver)
    return (value.value,'snmp_ro','snmp_vers')       
#s=fun_snmp('10.218.59.86')
#print(s)
