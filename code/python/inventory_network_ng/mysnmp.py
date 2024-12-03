#!/usr/bin/env python3
import argparse
from easysnmp.variables import SNMPVariable
from easysnmp import snmp_get  # ,snmp_walk, snmp_set,
from easysnmp import (
    EasySNMPError,
    EasySNMPConnectionError,
    EasySNMPTimeoutError,
    EasySNMPUnknownObjectIDError,
    EasySNMPNoSuchObjectError,
    EasySNMPNoSuchInstanceError,
    EasySNMPUndeterminedTypeError
)

snmp_ro = ['Ut368my5NR', 'public', 'private']
snmp_oid_hostname = '.1.3.6.1.2.1.1.5.0'
snmp_version = [2, 1]
ip_def='10.100.27.15'

def fun_snmp(ip, oid=snmp_oid_hostname, snmp_v=snmp_version, snmp_r=snmp_ro):
    print('The function fun_snmp is read in the file mysnmp.py')
    print('ip:'+str(ip))
    for ver in snmp_v:
        for com in snmp_r:
            value = SNMPVariable('')
            print('\t\t\t snmp_version:'+str(ver) +
                  ' snmp_community:'+str(com)+' oid:'+str(oid))

            try:
                value = snmp_get(oid, hostname=ip, community=com,
                                 version=ver, retries=0, timeout=0.1)
            except EasySNMPConnectionError as e:
                print(f"ERROR: Problem connecting to the remote host. ({e}.)")
            except EasySNMPTimeoutError as e:
                print(f"ERROR: SNMP request times out. ({e}.)")
            except (EasySNMPUnknownObjectIDError, EasySNMPNoSuchObjectError, EasySNMPUndeterminedTypeError) as e:
                print(
                    f"ERROR: Nonexistent OID is requested/ \
                    Existence but is an invalid object name/ \
                    Type cannot be determined when setting the value of an OID. ({e}.)")
            except EasySNMPNoSuchInstanceError as e:
                print(f"ERROR: OID index requested from Net-SNMP doesn’t exist. ({e}.)")
            except EasySNMPError:
                print('ERROR: Other exceptions.')
            else:
                print('\t\t\t raw value answer:'+str(value.value))
                return (value.value, com, ver)
    return('','','')

               


if __name__ == '__main__':
    print('Launch file mysnmp.py')
    parser = argparse.ArgumentParser(description='SNMP Query script')
    parser.add_argument('--ip','-ip', type=str, default=ip_def, dest='ip', help='IP address of the SNMP device (default: 10.100.27.10)')
    args = parser.parse_args()
    ip = args.ip
    fun_snmp(ip, oid=snmp_oid_hostname, snmp_v=snmp_version, snmp_r=snmp_ro)
