#!/usr/bin/env python3
snmp_oid_enter='.1.3.6.1.2.1.1.2.0'
snmp_oid_name='1.3.6.1.2.1.1.5.0'
import mysnmp
import re
class Model():
    def __init__(self,ip,snmp_r,snmp_v,vendor='Vendor',model='Model',firmware='Firmware',ipplandesc='IPPlanDesc',type='Type'):
        self.ip=ip
        self.vendor=vendor
        self.model=re.sub("[^a-zA-Z0-9/_()-+]","_",model)[0:70]
        self.firmware=firmware
        self.type=type
        self.ipplandesc=ipplandesc
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware='Firmware'
#EDGE_CORE
class EdgeCore_ES3528M():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='EdgeCore'
        self.model='ES3528M'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.1.3.1.6.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

class EdgeCore_ES3552M():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='EdgeCore'
        self.model='ES3552M'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.1.3.1.6.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
     
class EdgeCore_ES3510MA():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='EdgeCore'
        self.model='ES3510MA'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.1.3.1.6.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.oid_ent_tree=re.sub(r'\.101$','',self.oid_ent_tree)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

class EdgeCore_ES3510MAv2():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='EdgeCore'
        self.model='ES3510MAv2'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.1.3.1.6.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.oid_ent_tree=re.sub(r'\.105$','',self.oid_ent_tree)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

class EdgeCore_ECS3510_28T():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='EdgeCore'
        self.model='ECS3510_28T'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.1.3.1.6.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.oid_ent_tree=re.sub(r'\.101$','',self.oid_ent_tree)
        self.oid_ent_tree=re.sub(r'\.102$','',self.oid_ent_tree)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

class EdgeCore_ECS3510_52T():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='EdgeCore'
        self.model='ECS3510_52T'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.1.3.1.6.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.oid_ent_tree=re.sub(r'\.101$','',self.oid_ent_tree)
        self.oid_ent_tree=re.sub(r'\.102$','',self.oid_ent_tree)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

class EdgeCore_ES4626_SFP():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='EdgeCore'
        self.model='ES4626_SFP'
        self.type='switchl3'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.100.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
#DLINK
class DLink_DES_1210_10ME():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='DLink'
        self.model='DES_1210_10ME'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        
class DLink_DES_1210_28ME():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='DLink'
        self.model='DES_1210_28ME'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

class DLink_DES_1210_52ME():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='DLink'
        self.model='DES_1210_52ME'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

class DLink_DES_3200_10():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='DLink'
        self.model='DES_3200_10'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.12.1.2.7.1.2.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.oid_ent_tree=re.sub(r'\.10\.113\.5\.1$','',self.oid_ent_tree)
        self.oid_ent_tree=re.sub(r'\.10\.113\.2\.1$','',self.oid_ent_tree)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        
class DLink_DES_3200_28():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='DLink'
        self.model='DES_3200_28'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.12.1.2.7.1.2.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.oid_ent_tree=re.sub(r'\.10\.113\.5\.1$','',self.oid_ent_tree)
        self.oid_ent_tree=re.sub(r'\.10\.113\.2\.1$','',self.oid_ent_tree)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        
class DLink_DES_3200_52():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='DLink'
        self.model='DES_3200_52'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.12.1.2.7.1.2.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.oid_ent_tree=re.sub(r'\.10\.113\.5\.1$','',self.oid_ent_tree)
        self.oid_ent_tree=re.sub(r'\.10\.113\.2\.1$','',self.oid_ent_tree)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

class DLink_DGS_1100_08():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='DLink'
        self.model='DGS_1100_08'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.12.1.2.7.1.2.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.oid_ent_tree=re.sub(r'\.10\.113\.5\.1$','',self.oid_ent_tree)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware='Firmware'

#HUAWEI
class Huawei_S2328P_EI_AC():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Huawei'
        self.model='S2328P_EI_AC'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r" \(.*","",self.firmware)

class Huawei_S2352P_EI():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Huawei'
        self.model='S2352P-EI'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r" \(.*","",self.firmware)

class Huawei_S5320_28X_LI_24S_AC():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Huawei'
        self.model='S5320_28X_LI_24S_AC'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r" \(.*","",self.firmware)

class Huawei_S5320_LI_24S_AC():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Huawei'
        self.model='S5320_LI_24S_AC'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r" \(.*","",self.firmware)

class Huawei_S5300_28P_LI_BAT():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Huawei'
        self.model='S5300_28P_LI_BAT'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r" \(.*","",self.firmware)       
#CISCO
class Cisco_WS_C2950T_24():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='WS_C2950T_24'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r"\(.*","",self.firmware)

class Cisco_WS_C2960G_24TC_L():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='WS_C2960G_24TC_L'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r"\(.*","",self.firmware)

class Cisco_WS_C2960_24TT_L():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='WS_C2960_24TT_L'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r"\(.*","",self.firmware)
        
class Cisco_ASR_9001():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='ASR_9001'
        self.type='router'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r"\[.*","",self.firmware)

class Cisco_ASR_9001():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='ASR_9010'
        self.type='router'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r"\[.*","",self.firmware)

class Cisco_ASR_1006():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='ASR_1006'
        self.type='router'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r",.*","",self.firmware)

class Cisco_2821():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='2821'
        self.type='router'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r",.*","",self.firmware)

class Cisco_WS_C3750G_24TS_S1U():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='WS_C3750G_24TS_S1U'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r",.*","",self.firmware)

class Cisco_3845():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='3845'
        self.type='router'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r",.*","",self.firmware)

class Cisco_ME_3600X_24FS_M():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='ME_3600X_24FS_M'
        self.type='switchl3'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.2.1.73.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.oid_ent_tree=re.sub(r'\.1\.1250$','',self.oid_ent_tree)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware=re.sub(r".*/","",self.firmware)
        self.firmware=re.sub(r".bin","",self.firmware)
        
class Cisco_ME_3600X_24CX_M():
    def __init__(self,ip,snmp_r,snmp_v,model,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='ME_3600X_24CX_M'
        self.type='switchl3'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'0.0.0.0'
        self.getfirmware(model)
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self,model):
        self.firmware=re.sub(r".*Version ","",model)
        self.firmware=re.sub(r",.*","",self.firmware)        

class Cisco_NCS_540():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Cisco'
        self.model='NCS_540'
        self.type='switchl3'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        '''self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.0.0.0.0'''
        self.oid_fw='.1.3.6.1.2.1.1.1.0'
        self.getfirmware()
        if self.firmware == None: self.firmware='Firmware'''
    '''def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)'''
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware=re.sub(r".*Version ","",self.firmware)
        self.firmware=re.split(" ",self.firmware)
        self.firmware=str(self.firmware[0])
        
#Optical receiver
#Planar
class Planar_SDO3002():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Planar'
        self.model='SDO3002'
        self.type='optical_receiver'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.6.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

class Planar_SDO3001():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Planar'
        self.model='SDO3001'
        self.type='optical_receiver'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.6.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)


class Planar_tuz19_2003():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Planar'
        self.model='tuz19_2003'
        self.type='optical_receiver'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.6.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)  
        self.firmware=re.sub("[^a-zA-Z0-9 _,.()-]+", "", self.firmware)
        
class Planar_tuz19_4001():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Planar'
        self.model='tuz19_4001'
        self.type='optical_receiver'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)  
        self.firmware=re.sub("[^a-zA-Z0-9 _,.()-]+", "", self.firmware)
#Vector       
class Vector_Lambda_PRO_72():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Vector'
        self.model='Lambda_PRO_72'
        self.type='optical_receiver'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.5.2.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.6.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware=re.sub("[^a-zA-Z0-9 _,.()-]+", "", self.firmware)

#FiberLabs_OR_862
class FiberLabs_OR_862():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='FiberLabs'
        self.model='OR_862'
        self.type='optical_receiver'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.5.2.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.6.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware='4.9.4'
        
#UPS and RS232_Eth
#HUAWEI
class Huawei_UPS2000():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Huawei'
        self.model='UPS2000'
        self.type='ups'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw='.1.3.6.1.4.1.2011.6.174.1.2.100.1.3.1'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.6.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)

#DELTA
class Delta_GES102R():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Delta'
        self.model='GES102R'
        self.type='ups'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.6.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware='4.9.4'
    
#MOXA
class Moxa_NP5150():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='Moxa'
        self.model='NP5150'
        self.type='RS232_Eth'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw=self.oid_ent_tree+'.1.3.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.6.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware='3.4'

#FiberHome
class FiberHome_S4820_52T_X():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='FiberHome'
        self.model='S4820_52T_X'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw='.1.3.6.1.4.1.3807.1.8012.2.1.4.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.5.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware=re.sub(r".*Version ","",self.firmware)
        self.firmware=re.split("[ |,]",self.firmware)
        if len(self.firmware) == 4:
            self.firmware=str(self.firmware[0])+' '+str(self.firmware[3])
        else:
           self.firmware=str(self.firmware[0]) 
        
class FiberHome_S4820_28T_X():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='FiberHome'
        self.model='S4820_28T_X'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw='.1.3.6.1.4.1.3807.1.8012.2.1.4.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.5.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware=re.sub(r".*Version ","",self.firmware)
        self.firmware=re.split("[ |,]",self.firmware)
        if len(self.firmware) == 4:
            self.firmware=str(self.firmware[0])+' '+str(self.firmware[3])
        else:
           self.firmware=str(self.firmware[0]) 

        
class FiberHome_S4820_52T_XL():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='FiberHome'
        self.model='S4820_52T_XL'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw='.1.3.6.1.4.1.3807.1.8012.2.1.4.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.5.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware=re.sub(r".*Version ","",self.firmware)
        self.firmware=re.split("[ |,]",self.firmware)
        if len(self.firmware) == 4:
            self.firmware=str(self.firmware[0])+' '+str(self.firmware[3])
        else:
           self.firmware=str(self.firmware[0]) 
        
class FiberHome_S4820_28T_XL():
    def __init__(self,ip,snmp_r,snmp_v,ipplandesc):
        self.ip=ip
        self.vendor='FiberHome'
        self.model='S4820_28T_XL'
        self.type='switch'
        self.ipplandesc=ipplandesc
        self.oid_enter=snmp_oid_enter
        self.snmp_r=[snmp_r]
        self.snmp_v=[snmp_v]
        self.getname()
        self.getenterprize()
        self.oid_fw='.1.3.6.1.4.1.3807.1.8012.2.1.4.0'
        self.getfirmware()
        if self.oid_ent_tree == None: self.oid_ent_tree='Oid_ent_tree'
        if self.name == None: self.name='Hostname'
        if self.firmware == None: self.firmware='Firmware'
    def getenterprize(self):
        self.oid_ent_tree,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_enter,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
    def getname(self):
        snmp_oid_name='1.3.6.1.2.1.1.5.0'
        self.name,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=snmp_oid_name,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.name=re.sub("[^a-zA-Z0-9 /_,.()-]+", "", self.name)
    def getfirmware(self):
        self.firmware,trash1,trash2=mysnmp.fun_snmp(self.ip,oid=self.oid_fw,snmp_r=self.snmp_r,snmp_v=self.snmp_v)
        self.firmware=re.sub(r".*Version ","",self.firmware)
        self.firmware=re.split("[ |,]",self.firmware)
        if len(self.firmware) == 4:
            self.firmware=str(self.firmware[0])+' '+str(self.firmware[3])
        else:
           self.firmware=str(self.firmware[0]) 
     