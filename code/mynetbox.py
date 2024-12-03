#!/usr/bin/env python3
import requests
import json
import os
import sys
import argparse


act_def = 'get_pref'

oxtoken='59557e7a8fbb97976e3eba9584dc3524246e1633'
oxurl='http://10.50.3.83'
oxport='8000'

headers = {
    'Authorization': f'Token {oxtoken}',
    'Content-Type': 'application/json',
}

global netinf
netinf = []

def fun_get_pref():
    print('The function fun_get_pref is read in the file mynetbox.py')
    global netinf
    netinf=[]
    try:
        response = requests.get(f'{oxurl}:{oxport}/api/ipam/prefixes/?limit=0', headers=headers)
        response.raise_for_status() 
        prefixes = response.json() 
        prefixes = prefixes['results']
    except requests.exceptions.RequestException as e:
        print(f'Error fetching prefixes: {e}')
        prefixes = []
        
        if not prefixes:
            print('Reading from file...')
            if os.path.exists("prefixes.txt"):
                with open("prefixes.txt", "r") as file:
                    try:
                        prefixes = json.load(file) 
                    except json.JSONDecodeError as e:
                        print(f"Error reading JSON from file: {e}")
                        prefixes = []
            else:
                print("File not found. No prefixes available.")
                prefixes = []
        else:
            print('Writing to file...')
            with open("prefixes.txt", "w") as file:
                json.dump(prefixes, file)
            
        if prefixes == []: 
            print('Error: prefixes empty')
            return []

    for prefix in prefixes:
        #print(f"prefix: {prefix['prefix']}, status: {prefix['status']['value']}")
        if not prefix['status']['value'] == 'active' : continue
    
        net=prefix['prefix']
        
        t=[]
        for tag in prefix["tags"]:
            #print(tag["name"])
            t.append(tag["name"])
        netboxtag=', '.join(t)     
        netinf.append({'ip': net, 'netboxtag': netboxtag})
    
    print(netinf)
    return(netinf)

def fun_get_net():
    print('The function fun_get_net is read in the file mynetbox.py')
    try:
        response = requests.get(f'{oxurl}:{oxport}/api/ipam/ip-addresses/', headers=headers)
        response.raise_for_status()
        results = response.json().get('results')
        if results == []:  print('Error fun_get_net'); return dict({})
        return(results)
    except requests.exceptions.RequestException as e:
        print(f'Error fun_get net {e}')
        return dict({})
    
    
def fun_get_ip(data):
    print('The function fun_get_ip is read in the file mynetbox.py')
    ip = data['address']
    try:
        response = requests.get(f'{oxurl}:{oxport}/api/ipam/ip-addresses/?address={ip}&address=string', headers=headers)
        response.raise_for_status()
        results = response.json().get('results')
        if results == []: print(f'IP {ip} not exists'); return dict({'id':''})
        i=''
        for row in results:
            i=row['id']
            ip=row['address']
            if i: print('id: '+str(i)+' address:'+str(ip));return row; continue
    except requests.exceptions.RequestException as e:
        print(f"Error checking IP address {ip}: {e}")
        return dict({'id':''})
    

    
def fun_del_ip(data):
    print('The function fun_del_ip is read in the file mynetbox.py')
    ip = data['address']
    i = fun_get_ip(data)['id']
    if not i == '':
        print(f"IP address {ip} already exists. Deleting existing entry...")
        try:
            response = requests.delete(f'{oxurl}:{oxport}/api/ipam/ip-addresses/{i}', headers=headers)
            response.raise_for_status()
            print(f"Deleted IP address: {ip}, id: {i}")
        except requests.exceptions.RequestException as e:
            print(f"Error deleting IP address: {e}")


def fun_set_ip(data):
    print('The function fun_set_ip is read in the file mynetbox.py')
    i = fun_get_ip(data)['id']
    ip = data['address']
    if i == '':
        print(f'Inser ip: {ip}')
        try:
            response = requests.post(f'{oxurl}:{oxport}/api/ipam/ip-addresses/', headers=headers, json=data)
            response.raise_for_status()
            if response.status_code == 201:
                #print("IP address added successfully:", response.json())
                print("IP address added successfully")
            else:
                print("Failed to add IP address:", response.status_code, response.text)
        except requests.exceptions.RequestException as e:
            print(f'Error fetching prefixes: {e}')
            return []
    else:
        print(f'Update id: {i}')
        response = requests.patch(f'{oxurl}:{oxport}/api/ipam/ip-addresses/{i}/', headers=headers, json=data)
        response.raise_for_status()
        if response.status_code == 200:
            print("IP address update successfully")
        else:
            print("Failed update IP address:")

if __name__ == '__main__':
    print('Launch file mynetbox.py')
    parser = argparse.ArgumentParser()
    sys.argv = ['sys.argv[0]', '--act', 'set_ip']
    
    parser.add_argument('--act', '-act', type=str, dest='action',
                        default=act_def, help='INPUT actions')
    
    if parser.parse_args().action: action = parser.parse_args().action
    
    data = {'address': '127.0.0.1/32', 'status': 'active', 'comments': 'COMMENTS', 'status': 'active', 'custom_fields': {'Firmware': 'firm','Model': 'mod','Vendor': 'vend'}, 'description': 'abc'}
    data = {'address': '127.0.0.11/32', 
            'custom_fields': {'Firmware': 'v7.0.0.1', 'Model': 'Mod', 'Vendor': 'Ven12d'},
            'status': 'active',
            }   

    #data = {'id': 72, 'address': '10.100.22.2/32', 'status': 'deprecated', 'comments': 'COM'}

    if action == 'get_pref':
        fun_get_pref()
    if action == 'set_ip':
        fun_set_ip(data)
    if action == 'del_ip':
        fun_del_ip(data)
    if action == 'get_ip':
        fun_get_ip(data)
    if action == 'get_net':
            fun_get_net()
