#!/usr/bin/env python3
import sys
import os
import re
import argparse

sys.path.append('/root/bin/')
import mysnmp

oid_enter = '.1.3.6.1.2.1.1.2.0'
oid_name = '.1.3.6.1.2.1.1.5.0'
oid_sysdescr='.1.3.6.1.2.1.1.1.0'

oid_ifindex = '.1.3.6.1.2.1.4.20.1.2.'
oid_physaddress = '.1.3.6.1.2.1.2.2.1.6.'
oid_ifdescr = '.1.3.6.1.2.1.2.2.1.2.'


model = ''
model_def = 'Huawei_S5731_H48P4XC'
ip_def = '10.100.27.15'
com_def = 'Ut368my5NR'
ver_def = 2
desc_def = 'netboxtag'

sys.argv = ['sys.argv[0]', \
    '-ip','10.100.27.14', '-model','Huawei_S5731_H48P4XC', \
    '-community','Ut368my5NR', '-version','2', '-description','ipplanddescription']


class Model():
    def __init__(self, ip, snmp_r, snmp_v, netboxtag='netboxtag', vendor='Vendor', model='Model', firmware='Firmware', type='Type'):
        self.ip = ip
        self.vendor = vendor
        self.model = model
        self.type = type
        self.netboxtag = netboxtag
        self.snmp_r = [snmp_r]
        self.snmp_v = [snmp_v]
        
        self.name = ''
        self.ifindex = ''
        self.physaddress = ''
        self.ifdescr = ''
        self.oid_ent_tree = ''
        self.firmware = ''
 
        self.getname()
        self.getmngmt()
        #self.getenterprize()
        #self.oid_fw = self.oid_ent_tree+'.1.1.3.1.6.1'
        #self.oid_fw = oid_sysdescr
        #self.getfirmware()
        

        if not self.name: self.name = 'Hostname'
        if not self.ifindex: self.ifindex = 'Ifindex'
        if not self.physaddress: self.physaddress = 'Physaddress'
        if not self.ifdescr: self.ifdescr = 'Ifdescr'
        if not self.oid_ent_tree: self.oid_ent_tree = 'Oid_ent_tree'
        if not self.firmware: self.firmware = 'Firmware'
        
    def getmngmt(self):
        self.ifindex, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifindex+self.ip, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.physaddress, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_physaddress+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.ifdescr, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifdescr+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
 
        self.hex_mac = self.physaddress.strip() #Remove any leading/trailing whitespace
        self.byte_array = self.hex_mac.encode('latin1') #Use 'latin1' to preserve byte values
        self.physaddress = ':'.join(format(byte, '02x') for byte in self.byte_array).lower()
        
    def getenterprize(self):
        self.oid_ent_tree, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_enter, snmp_r=self.snmp_r, snmp_v=self.snmp_v)

    def getname(self):
        self.name, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_name, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.name = re.sub('[^A-Za-z0-9-,._]', '', self.name)

    def getfirmware(self):
        self.firmware, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=self.oid_fw, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.firmware = re.search(r'Version (\d+\.\d+) \(\S+ (\S+)\)', self.firmware)
        self.firmware = self.firmware.group(1)+' '+self.firmware.group(2)

        
        
# Huawei
class Huawei_S6735S_S48X6C_A():

    def __init__(self, ip, snmp_r, snmp_v, netboxtag):
        self.ip = ip
        self.vendor = 'Huawei'
        self.model = 'S6735S_S48X6C_A'
        self.type = 'switch'
        self.netboxtag = netboxtag
        self.snmp_r = [snmp_r]
        self.snmp_v = [snmp_v]
        
        self.name = ''
        self.ifindex = ''
        self.physaddress = ''
        self.ifdescr = ''
        self.oid_ent_tree = ''
        self.firmware = ''
 
        self.getname()
        self.getmngmt()
        #self.getenterprize()
        #self.oid_fw = self.oid_ent_tree+'.1.1.3.1.6.1'
        self.oid_fw = oid_sysdescr
        self.getfirmware()
        

        if not self.name: self.name = 'Hostname'
        if not self.ifindex: self.ifindex = 'Ifindex'
        if not self.physaddress: self.physaddress = 'Physaddress'
        if not self.ifdescr: self.ifdescr = 'Ifdescr'
        if not self.oid_ent_tree: self.oid_ent_tree = 'Oid_ent_tree'
        if not self.firmware: self.firmware = 'Firmware'
        
    def getmngmt(self):
        self.ifindex, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifindex+self.ip, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.physaddress, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_physaddress+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.ifdescr, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifdescr+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
 
        self.hex_mac = self.physaddress.strip() #Remove any leading/trailing whitespace
        self.byte_array = self.hex_mac.encode('latin1') #Use 'latin1' to preserve byte values
        self.physaddress = ':'.join(format(byte, '02x') for byte in self.byte_array).lower()
        
    def getenterprize(self):
        self.oid_ent_tree, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_enter, snmp_r=self.snmp_r, snmp_v=self.snmp_v)

    def getname(self):
        self.name, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_name, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.name = re.sub('[^A-Za-z0-9-,._]', '', self.name)

    def getfirmware(self):
        self.firmware, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=self.oid_fw, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.firmware = re.search(r'Version (\d+\.\d+) \(\S+ (\S+)\)', self.firmware)
        self.firmware = self.firmware.group(1)+' '+self.firmware.group(2)
        

class Huawei_S5731_H48P4XC():

    def __init__(self, ip, snmp_r, snmp_v, netboxtag):
        self.ip = ip
        self.vendor = 'Huawei'
        self.model = 'S5731_H48P4XC'
        self.type = 'switch'
        self.netboxtag = netboxtag
        self.snmp_r = [snmp_r]
        self.snmp_v = [snmp_v]
        
        self.name = ''
        self.ifindex = ''
        self.physaddress = ''
        self.ifdescr = ''
        self.oid_ent_tree = ''
        self.firmware = ''
 
        self.getname()
        self.getmngmt()
        #self.getenterprize()
        #self.oid_fw = self.oid_ent_tree+'.1.1.3.1.6.1'
        self.oid_fw = oid_sysdescr
        self.getfirmware()
        

        if not self.name: self.name = 'Hostname'
        if not self.ifindex: self.ifindex = 'Ifindex'
        if not self.physaddress: self.physaddress = 'Physaddress'
        if not self.ifdescr: self.ifdescr = 'Ifdescr'
        if not self.oid_ent_tree: self.oid_ent_tree = 'Oid_ent_tree'
        if not self.firmware: self.firmware = 'Firmware'
        
    def getmngmt(self):
        self.ifindex, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifindex+self.ip, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.physaddress, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_physaddress+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.ifdescr, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifdescr+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
 
        self.hex_mac = self.physaddress.strip() #Remove any leading/trailing whitespace
        self.byte_array = self.hex_mac.encode('latin1') #Use 'latin1' to preserve byte values
        self.physaddress = ':'.join(format(byte, '02x') for byte in self.byte_array).lower()
        
    def getenterprize(self):
        self.oid_ent_tree, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_enter, snmp_r=self.snmp_r, snmp_v=self.snmp_v)

    def getname(self):
        self.name, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_name, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.name = re.sub('[^A-Za-z0-9-,._]', '', self.name)

    def getfirmware(self):
        self.firmware, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=self.oid_fw, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.firmware = re.search(r'Version (\d+\.\d+) \(\S+ (\S+)\)', self.firmware)
        self.firmware = self.firmware.group(1)+' '+self.firmware.group(2)

class Huawei_S5731_S48P4X():

    def __init__(self, ip, snmp_r, snmp_v, netboxtag):
        self.ip = ip
        self.vendor = 'Huawei'
        self.model = 'S5731_S48P4X'
        self.type = 'switch'
        self.netboxtag = netboxtag
        self.snmp_r = [snmp_r]
        self.snmp_v = [snmp_v]
        
        self.name = ''
        self.ifindex = ''
        self.physaddress = ''
        self.ifdescr = ''
        self.oid_ent_tree = ''
        self.firmware = ''
 
        self.getname()
        self.getmngmt()
        #self.getenterprize()
        #self.oid_fw = self.oid_ent_tree+'.1.1.3.1.6.1'
        self.oid_fw = oid_sysdescr
        self.getfirmware()
        

        if not self.name: self.name = 'Hostname'
        if not self.ifindex: self.ifindex = 'Ifindex'
        if not self.physaddress: self.physaddress = 'Physaddress'
        if not self.ifdescr: self.ifdescr = 'Ifdescr'
        if not self.oid_ent_tree: self.oid_ent_tree = 'Oid_ent_tree'
        if not self.firmware: self.firmware = 'Firmware'
        
    def getmngmt(self):
        self.ifindex, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifindex+self.ip, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.physaddress, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_physaddress+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.ifdescr, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifdescr+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
 
        self.hex_mac = self.physaddress.strip() #Remove any leading/trailing whitespace
        self.byte_array = self.hex_mac.encode('latin1') #Use 'latin1' to preserve byte values
        self.physaddress = ':'.join(format(byte, '02x') for byte in self.byte_array).lower()
        
    def getenterprize(self):
        self.oid_ent_tree, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_enter, snmp_r=self.snmp_r, snmp_v=self.snmp_v)

    def getname(self):
        self.name, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_name, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.name = re.sub('[^A-Za-z0-9-,._]', '', self.name)

    def getfirmware(self):
        self.firmware, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=self.oid_fw, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.firmware = re.search(r'Version (\d+\.\d+) \(\S+ (\S+)\)', self.firmware)
        self.firmware = self.firmware.group(1)+' '+self.firmware.group(2)


class Huawei_S5731_S24T4X():

    def __init__(self, ip, snmp_r, snmp_v, netboxtag):
        self.ip = ip
        self.vendor = 'Huawei'
        self.model = 'S5731_S24T4X'
        self.type = 'switch'
        self.netboxtag = netboxtag
        self.snmp_r = [snmp_r]
        self.snmp_v = [snmp_v]
        
        self.name = ''
        self.ifindex = ''
        self.physaddress = ''
        self.ifdescr = ''
        self.oid_ent_tree = ''
        self.firmware = ''
 
        self.getname()
        self.getmngmt()
        #self.getenterprize()
        #self.oid_fw = self.oid_ent_tree+'.1.1.3.1.6.1'
        self.oid_fw = oid_sysdescr
        self.getfirmware()
        

        if not self.name: self.name = 'Hostname'
        if not self.ifindex: self.ifindex = 'Ifindex'
        if not self.physaddress: self.physaddress = 'Physaddress'
        if not self.ifdescr: self.ifdescr = 'Ifdescr'
        if not self.oid_ent_tree: self.oid_ent_tree = 'Oid_ent_tree'
        if not self.firmware: self.firmware = 'Firmware'
        
    def getmngmt(self):
        self.ifindex, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifindex+self.ip, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.physaddress, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_physaddress+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.ifdescr, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifdescr+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
 
        self.hex_mac = self.physaddress.strip() #Remove any leading/trailing whitespace
        self.byte_array = self.hex_mac.encode('latin1') #Use 'latin1' to preserve byte values
        self.physaddress = ':'.join(format(byte, '02x') for byte in self.byte_array).lower()
        
    def getenterprize(self):
        self.oid_ent_tree, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_enter, snmp_r=self.snmp_r, snmp_v=self.snmp_v)

    def getname(self):
        self.name, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_name, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.name = re.sub('[^A-Za-z0-9-,._]', '', self.name)

    def getfirmware(self):
        self.firmware, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=self.oid_fw, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.firmware = re.search(r'Version (\d+\.\d+) \(\S+ (\S+)\)', self.firmware)
        self.firmware = self.firmware.group(1)+' '+self.firmware.group(2)
        

class Huawei_S5735():

    def __init__(self, ip, snmp_r, snmp_v, netboxtag):
        self.ip = ip
        self.vendor = 'Huawei'
        self.model = 'S5735'
        self.type = 'switch'
        self.netboxtag = netboxtag
        self.snmp_r = [snmp_r]
        self.snmp_v = [snmp_v]
        
        self.name = ''
        self.ifindex = ''
        self.physaddress = ''
        self.ifdescr = ''
        self.oid_ent_tree = ''
        self.firmware = ''
 
        self.getname()
        self.getmngmt()
        #self.getenterprize()
        #self.oid_fw = self.oid_ent_tree+'.1.1.3.1.6.1'
        self.oid_fw = oid_sysdescr
        self.getfirmware()
        

        if not self.name: self.name = 'Hostname'
        if not self.ifindex: self.ifindex = 'Ifindex'
        if not self.physaddress: self.physaddress = 'Physaddress'
        if not self.ifdescr: self.ifdescr = 'Ifdescr'
        if not self.oid_ent_tree: self.oid_ent_tree = 'Oid_ent_tree'
        if not self.firmware: self.firmware = 'Firmware'
        
    def getmngmt(self):
        self.ifindex, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifindex+self.ip, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.physaddress, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_physaddress+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.ifdescr, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_ifdescr+self.ifindex, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
 
        self.hex_mac = self.physaddress.strip() #Remove any leading/trailing whitespace
        self.byte_array = self.hex_mac.encode('latin1') #Use 'latin1' to preserve byte values
        self.physaddress = ':'.join(format(byte, '02x') for byte in self.byte_array).lower()
        
    def getenterprize(self):
        self.oid_ent_tree, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_enter, snmp_r=self.snmp_r, snmp_v=self.snmp_v)

    def getname(self):
        self.name, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=oid_name, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.name = re.sub('[^A-Za-z0-9-,._]', '', self.name)

    def getfirmware(self):
        self.firmware, trash1, trash2 = mysnmp.fun_snmp(
            self.ip, oid=self.oid_fw, snmp_r=self.snmp_r, snmp_v=self.snmp_v)
        self.firmware = re.search(r'Version (\d+\.\d+) \(\S+ (\S+)\)', self.firmware)
        self.firmware = self.firmware.group(1)+' '+self.firmware.group(2)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Description of device characteristics and OID')
        
    parser.add_argument('--model', '-model', type=str, dest='model',
                        default=model_def, help='INPUT device model')
    parser.add_argument('--ip', '-ip', type=str, dest='ip',
                        default=ip_def, help='INPUT ip device')
    parser.add_argument('--community', '-community', type=str, dest='community',
                        default=com_def, help='INPUT device snmp ro community')
    parser.add_argument('--version', '-version', type=int, dest='version',
                        default=ver_def, help='INPUT version snmp')
    parser.add_argument('--description', '-description', type=str, dest='description',
                        default=desc_def, help='INPUT description subnet network')

    if parser.parse_args().ip: ip = parser.parse_args().ip
    if parser.parse_args().model: model = parser.parse_args().model
    if parser.parse_args().community: snmp_r = parser.parse_args().community
    if parser.parse_args().version: snmp_v = parser.parse_args().version
    if parser.parse_args().description: netboxtag = parser.parse_args().description
    try:
        device = globals()[model](ip, snmp_r, snmp_v, netboxtag)
    except Exception as e:
        print(f"\t\t\t Except: {e}")
    else:
        print(device); print(type(device))
