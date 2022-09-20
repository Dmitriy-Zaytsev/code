#!/usr/bin/env python3
#%reset -f
import sys;sys.path.append('/root')
from imp import reload
import re
import mysnmp
import myping
import myipaddr
import mymodelclass
import myprint
#import mymysql
import mypostgresql
from threading import Thread
import os;os.system('ulimit -n 1000000')
from random import randrange
from time import sleep
import argparse

from config_inventory import *


#network=[{'ip':'172.19.0.13/32', 'ipplandesc':'mysw'},{'ip':'192.168.33.0/24', 'ipplandesc':'network33'}]
#network=[{'ip':'172.19.0.13', 'ipplandesc':'mysw'}]
#network=[{'ip':'10.218.61.125', 'ipplandesc':'switch'}]
#network=[{'ip':'10.218.62.132', 'ipplandesc':'n-port'}]
#network=[{'ip':'10.218.60.106', 'ipplandesc':'loopback'}]

IP=''
parser = argparse.ArgumentParser()
parser.add_argument('-i', '--ipaddress' , help='INPUT ipaddress', action='store', type=str, dest='IP')

if parser.parse_args().IP: network=[{'ip':parser.parse_args().IP, 'ipplandesc':'test'}]

NET=myipaddr.fun_addrrange(network)

def fun_start(ip,ipplandesc):
    print(myping.fun_ping(ip))
    if myping.fun_ping(ip) == False : print('error ',ip); mypostgresql.fun_error(ip); return 10
    model,snmp_r,snmp_v=mysnmp.fun_snmp(ip,oid='.1.3.6.1.2.1.1.1.0')
    if model == '' : 
        m_temp,snmp_r,snmp_v=mysnmp.fun_snmp(ip,oid='.1.3.6.1.2.1.2.2.1.2.1')
        if re.search('.*Moxa.*',m_temp): model=m_temp
    if re.search('.*Fengine Sw Ver USP *',model):
        model,snmp_r,snmp_v=mysnmp.fun_snmp(ip,oid='.1.3.6.1.4.1.3807.2.1206.1.3.4.0')
    if model == None: print('model none ',ip);return 20
    if model == '': print('model null ',ip);return 30
    model=re.sub("[^a-zA-Z0-9 _,.()\[\]-]+", "", model)
    print(model)
    if re.search('[cC]isco',model):
        model2=str(model)
        model,snmp_r,snmp_v=mysnmp.fun_snmp(ip,oid='.1.3.6.1.2.1.47.1.1.1.1.13.1',snmp_r=[snmp_r],snmp_v=[snmp_v])
        if re.search('NOSUCHINSTANCE',model) or model == None or model == '': model,snmp_r,snmp_v=mysnmp.fun_snmp(ip,oid='.1.3.6.1.2.1.47.1.1.1.1.13.1001',snmp_r=[snmp_r],snmp_v=[snmp_v])
        if re.search('NOSUCHINSTANCE',model) or model == None or model == '': model,snmp_r,snmp_v=mysnmp.fun_snmp(ip,oid='iso.3.6.1.2.1.47.1.1.1.1.13.24555730',snmp_r=[snmp_r],snmp_v=[snmp_v])
    print(model)
    #Edge Core
    if re.search('.*ES3510MA$',model):
        device=mymodelclass.EdgeCore_ES3510MA(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*ES3510MAv2$',model):
        device=mymodelclass.EdgeCore_ES3510MAv2(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*ECS3510-28T.*',model): 
        device=mymodelclass.EdgeCore_ECS3510_28T(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*ECS3510-52T.*',model): 
        device=mymodelclass.EdgeCore_ECS3510_52T(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)      
    elif re.search('.*ES3528M.*',model): 
        device=mymodelclass.EdgeCore_ES3528M(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*ES3552M.*',model): 
        device=mymodelclass.EdgeCore_ES3552M(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*ES4626.*SFP.*',model): 
        device=mymodelclass.EdgeCore_ES4626_SFP(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    #DLink
    elif re.search('.*DES-1210-10ME.*',model): 
        device=mymodelclass.DLink_DES_1210_10ME(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*DES-1210-28ME.*',model): 
        device=mymodelclass.DLink_DES_1210_28ME(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*DES-1210-52ME.*',model): 
        device=mymodelclass.DLink_DES_1210_52ME(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*DES-3200-10.*',model): 
        device=mymodelclass.DLink_DES_3200_10(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*DES-3200-28.*',model): 
        device=mymodelclass.DLink_DES_3200_28(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*DES-3200-28.*',model): 
        device=mymodelclass.DLink_DES_3200_52(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*Realtek-Switch.*',model): 
        device=mymodelclass.DLink_DGS_1100_08(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    #Huawei
    elif re.search('.*S2328P-EI-AC.*',model): 
        device=mymodelclass.Huawei_S2328P_EI_AC(ip,snmp_r,snmp_v,model,ipplandesc=ipplandesc)
    elif re.search('.*S2352P-EI.*',model): 
        device=mymodelclass.Huawei_S2352P_EI(ip,snmp_r,snmp_v,model,ipplandesc=ipplandesc)
    elif re.search('.*S5320-28X-LI-24S-AC.*',model): 
        device=mymodelclass.Huawei_S5320_28X_LI_24S_AC(ip,snmp_r,snmp_v,model,ipplandesc=ipplandesc)
    elif re.search('.*S5300-28P-LI-BAT.*',model): 
        device=mymodelclass.Huawei_S5300_28P_LI_BAT(ip,snmp_r,snmp_v,model,ipplandesc=ipplandesc)
    elif re.search('.*S5320-LI-24S-AC.*',model): 
        device=mymodelclass.Huawei_S5320_LI_24S_AC(ip,snmp_r,snmp_v,model,ipplandesc=ipplandesc)
    elif re.search('.*Linux GSE200M.*',model): 
        device=mymodelclass.Huawei_UPS2000(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    #Cisco
    elif re.search('.*WS-C2950T-24.*',model): 
        device=mymodelclass.Cisco_WS_C2950T_24(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*WS-C2960G-24TC-L.*',model): 
        device=mymodelclass.Cisco_WS_C2960G_24TC_L(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*WS-C2960-24TT-L.*',model): 
        device=mymodelclass.Cisco_WS_C2960_24TT_L(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*WS-C3750G-24TS-S1U.*',model): 
        device=mymodelclass.Cisco_WS_C3750G_24TS_S1U(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*ME-3600X-24FS-M.*', model): 
        device=mymodelclass.Cisco_ME_3600X_24FS_M(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*ASR-9001*',model): 
        device=mymodelclass.Cisco_ASR_9001(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*ASR-9010*',model): 
        device=mymodelclass.Cisco_ASR_9001(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*ASR.*1006.*',model): 
        device=mymodelclass.Cisco_ASR_1006(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*ME-3600X-24CX-M.*',model): 
        device=mymodelclass.Cisco_ME_3600X_24CX_M(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*CISCO2821.*',model):
        device=mymodelclass.Cisco_2821(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*CISCO3845.*',model):
        device=mymodelclass.Cisco_3845(ip,snmp_r,snmp_v,model2,ipplandesc=ipplandesc)
    elif re.search('.*N540.*', model): 
        device=mymodelclass.Cisco_NCS_540(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    #Planar
    elif re.search('.*sdo3002.*',model): 
        device=mymodelclass.Planar_SDO3002(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*sdo3001.*',model): 
        device=mymodelclass.Planar_SDO3001(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*tuz19-2003.*',model): 
        device=mymodelclass.Planar_tuz19_2003(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*tuz19-4001.*',model): 
        device=mymodelclass.Planar_tuz19_4001(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    #Vector
    elif re.search('.*Lambda PRO 72.*',model): 
        device=mymodelclass.Vector_Lambda_PRO_72(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    #Fiber Labs
    elif re.search('.*V4\.9\.4\.*',model): 
        device=mymodelclass.FiberLabs_OR_862(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    #Delta
    elif re.search('.*UPS SNMP Agent.*',model): 
        device=mymodelclass.Delta_GES102R(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    #Moxa
    elif re.search('.*Moxa.*',model): 
        device=mymodelclass.Moxa_NP5150(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    #Fiber Home
    elif re.search('.*S4820-52T-X .*', model): 
        device=mymodelclass.FiberHome_S4820_52T_X(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*S4820-28T-X .*', model): 
        device=mymodelclass.FiberHome_S4820_28T_X(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*S4820-52T-XL .*', model): 
        device=mymodelclass.FiberHome_S4820_52T_XL(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    elif re.search('.*S4820-28T-XL .*', model): 
        device=mymodelclass.FiberHome_S4820_28T_XL(ip,snmp_r,snmp_v,ipplandesc=ipplandesc)
    else:
        device=mymodelclass.Model(ip,snmp_r,snmp_v,model=model,ipplandesc=ipplandesc)
    #myprint.fun_print(device)
    data=[device.ip,device.vendor,device.model,device.type,device.firmware,device.name,device.ipplandesc,0]
    #print(ip)
    #print(data)
    print('insert ',ip,data)
    mypostgresql.fun_insert(data)



for string in NET:
    #print(string['ip'])
    try:
        ip=str(string['ip'])
    except:
        continue
    try:
        ipplandesc=str(string['ipplandesc'])
    except:
        ipplandesc='IPPlanDesc'
    #fun_start(ip,ipplandesc)
    thread1 = Thread(target=fun_start,args=(ip,ipplandesc))
    print(ip)
    thread1.start()
thread1.join()
mypostgresql.fun_delete()
mypostgresql.fun_close()

