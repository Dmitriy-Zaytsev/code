#!/usr/bin/python3
from scapy.all import *
from sh import ip
from sh import systemctl
from sh import cat

T=True

IFACE='enp2s0.415'
MAC_PPPOE=['08:96:ad:ab:91:00',
'08:96:ad:ab:91:10',
'08:96:ad:ab:91:20',
'08:96:ad:ab:91:30']

AC_NAME=['HQ']
SN_NAME=['HQ']

def check_interface():
    while True == T:
        #a=str(ip('link','show', IFACE))
        param=str('/sys/class/net/'+IFACE+'/operstate')
        b=str(cat(param))
        #print(a)
        print(b)
        if "down" in b:
            ###systemctl('stop','NetworkManager.service')
            ###systemctl('start','NetworkManager.service')
            print('Interface:'+IFACE+' state DOWN')
            ip('link','set', IFACE,'up')
        else:
            print('Interface:'+IFACE+' state UP')
            break
 

def scan():
    check_interface()
    global s
    s=''
    global l
    l=[]
    mac = str(RandMAC())[8:17]
    mac = '92:d9:bc'+mac
    ETH = Ether(src=mac,dst='ff:ff:ff:ff:ff:ff', type=34915)

"""
    #№1
    PPPOE = PPPoED(sessionid=0, len=4, version=1, code=9, type=1)
    PPPOE_TAG = PPPoED_Tags(tag_list=[PPPoETag(tag_type=257, tag_len=0)])
    PADI = ETH/PPPOE/PPPOE_TAG
"""

    #№2
    PPPOED=PPPoED(code=9, tags=[PPPoE_Tag(type=257, len=0)], type=1, len=4, sessionid=0, version=1)
    PADI = ETH/PPPOED

    check_interface()
    ANS,UNANS = srp(PADI,iface=IFACE,filter='ether proto 0x8863',timeout=1,multi=True)  
    check_interface()
    global SERVER_LOST
    global S_L
    global SERVER_BAD
    SERVER_LOST=len(MAC_PPPOE)
    S_L=int(SERVER_LOST)
    SERVER_BAD=0
    print('\n'+'.'*130)

    for p in ANS:
        SERVER='False' 
        PADO = p[1]
        TIME = PADO.time
        MAC = PADO[Ether].src
        TAG_AC=''
        TAG_SN=''
        """
        #№1
        TAG = PADO[PPPoED_Tags].tag_list
        """
        #№2
        TAG = PADO[PPPoED].tags
        """
        #№1
        for t in TAG:
            if t.tag_type == 257:
                TAG_SN = t.tag_value
                TAG_SN = TAG_SN.decode('utf-8')
            elif t.tag_type == 258:
                TAG_AC = t.tag_value
                TAG_AC = TAG_AC.decode('utf-8')
        if len(TAG_AC) == 0: TAG_AC='None'
        if len(TAG_SN) == 0: TAG_SN='None'
        """
        #№2
        for t in TAG:
            #print(t)
            if t.type == 257:
                TAG_SN = t.data
                TAG_SN = TAG_SN.decode('utf-8')
            elif t.type == 258:
                TAG_AC = t.data
                TAG_AC = TAG_AC.decode('utf-8')
        if len(TAG_AC) == 0: TAG_AC='None'
        if len(TAG_SN) == 0: TAG_SN='None'
        
        ORG_MAC=' '
        for m in MAC_PPPOE:
            if MAC == m: ORG_MAC='MTS'
        ORG_SN=' '
        for a in AC_NAME:
            if TAG_SN == a: ORG_SN='MTS'
        ORG_AC=' '
        for s in SN_NAME:
            if TAG_AC == s: ORG_AC='MTS'
        #if ORG_MAC == 'MTS' and ORG_SN == 'MTS' and ORG_AC == 'MTS': SERVER='True'
        if ORG_MAC == 'MTS' and ORG_AC == 'MTS':
            SERVER='True'
            SERVER_LOST=SERVER_LOST-1
        else:
            SERVER_BAD=SERVER_BAD+1
        #print('MAC-AC:',MAC+'('+ORG_MAC+')','\tService-Name:',TAG_SN+'('+ORG_SN+')','\tAC-Name:',TAG_AC+'('+ORG_AC+')','\tServer:',SERVER)
        s='MAC-AC:'+MAC+'('+ORG_MAC+')\tService-Name:'+TAG_SN+'('+ORG_SN+')\tAC-Name:'+TAG_AC+'('+ORG_AC+')\tServer:'+SERVER
        l.append(s)    
    #print('.'*130)
    #print('Server-Lost:',SERVER_LOST,'/',S_L, '\tServer-Bad:',SERVER_BAD)
    s='Server-Lost:'+str(SERVER_LOST)+'/'+str(S_L)+'\tServer-Bad:'+str(SERVER_BAD)
    l.append(s)
    check_interface()
    return(l, SERVER_LOST,S_L, SERVER_BAD)

##while 1 == 1:
##    scan()
