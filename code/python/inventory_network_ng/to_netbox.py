# -*- coding: utf-8 -*-
"""
Created on Mon Dec  2 14:22:45 2024

@author: dszaitsev
"""

#!/usr/bin/env python3

import sys
from datetime import datetime, timedelta
sys.path.append('/root/bin/')
import mynetbox
import mypostgresql

before_day=10

current_date = datetime.now()
date_threshold = current_date - timedelta(days=before_day)



pgnet = mypostgresql.fun_select()

for st in pgnet:
    ip = st[0]; hostname = st[1]; vendor = st[2]; model = st[3]; type  = st[4];
    firmware  = st[5]; netboxtag = st[6]; mgint  = st[7]; mac  = st[8]; date = st[9]
    print(ip,hostname,vendor,model,type,firmware,netboxtag,mgint,mac,date)
    data = {'address': ip,'status': 'active', 'description': netboxtag,
            'custom_fields': 
                {'Firmware': firmware, 'Model': model, 'Vendor': vendor, 'Interface' : str(mac+'/'+mgint) },

            }
    mynetbox.fun_set_ip(data)



netboxnet=mynetbox.fun_get_net()

for st in netboxnet:
    # if datetime.strptime(st['last_updated'], '%Y-%m-%dT%H:%M:%S.%fZ') < date_threshold:
    #     stat = 'deprecated'
    # else:
    #     stat = 'active'
    
    # data = {'id': st['id'], 'address': st['address'], 'status': stat}
    # mynetbox.fun_set_ip(data)

    if datetime.strptime(st['last_updated'], '%Y-%m-%dT%H:%M:%S.%fZ') < date_threshold:
        data = {'id': st['id'], 'address': st['address'], 'status': 'deprecated'}
        mynetbox.fun_set_ip(data)
    
