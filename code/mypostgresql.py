#!/usr/bin/env python3
import psycopg2
from psycopg2 import InterfaceError
import argparse
import sys


dbuser = 'pyuser'
dbpassword = 'onpyth'
dbname = 'network'
dbport = 5432
dbip = '172.17.0.3'
dbtable = 'inventory_network'

global db
db = psycopg2.connect( user=dbuser,password=dbpassword, 
                     dbname=dbname,connect_timeout=20,port=dbport, host=dbip)
db.autocommit=True

#cursor = db.cursor()
#sql="DELETE FROM inventory_network"
#cursor.execute(sql)
#cursor.close()

ip=''
act=''
act_def='insert'
ip_def='10.100.27.10'


def fun_insert(data):
    global db
    sql_insert="INSERT INTO "+dbtable+" \
        (ip,hostname,vendor,model,type,firmware,netboxtag,mgint,mac,date,error) VALUES \
        ('{d[0]}','{d[1]}','{d[2]}','{d[3]}','{d[4]}','{d[5]}','{d[6]}','{d[7]}','{d[8]}',CURRENT_TIMESTAMP,0) \
        ON CONFLICT (ip) DO UPDATE SET hostname=EXCLUDED.hostname, vendor=EXCLUDED.vendor, model=EXCLUDED.model, \
        type=EXCLUDED.type, firmware=EXCLUDED.firmware, netboxtag=EXCLUDED.netboxtag, mgint=EXCLUDED.mgint, \
        mac=EXCLUDED.mac, date=EXCLUDED.date,error=0;".format(d=data)
    try:
        db = psycopg2.connect( user=dbuser,password=dbpassword, 
                      dbname=dbname,connect_timeout=20,port=dbport, host=dbip)
        cursor = db.cursor()

    except InterfaceError as e:
        print(f"\t\t\t Error connect PostgreSQL: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    else:
        cursor.execute(sql_insert)
        db.commit()
        # while cursor.rowcount <= 0:
        #     print('sql_insert: ',sql_insert)
        #     cursor.execute(sql_insert)
        # db.commit()
        # if cursor.rowcount > 0:
        #     print("Insert successful.")
        # else:
        #     print("Insert failed.")
    finally:
        if cursor is not None:
            cursor.close()
        if db is not None:
            db.close()


def fun_error(ip):
    global db
    sql_error="UPDATE "+dbtable+" SET error=error+1 WHERE  ip='{}';".format(ip)
    try:
        db = psycopg2.connect( user=dbuser,password=dbpassword, 
                      dbname=dbname,connect_timeout=20,port=dbport, host=dbip)
        cursor = db.cursor()
    except InterfaceError as e:
        print(f"\t\t\t Error connect PostgreSQL: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    else:
        cursor.execute(sql_error)
        db.commit()
    finally:
        if cursor is not None:
            cursor.close()
        if db is not None:
            db.close()



def fun_delete():
    global db
    #sql_delete="DELETE FROM inventory_network WHERE error>5"
    sql_delete="DELETE FROM "+dbtable+" WHERE date <= CURRENT_TIMESTAMP - INTERVAL '120 day'"
    try:
        db = psycopg2.connect( user=dbuser,password=dbpassword, 
                      dbname=dbname,connect_timeout=20,port=dbport, host=dbip)
        cursor = db.cursor()
    except InterfaceError as e:
        print(f"\t\t\t Error connect PostgreSQL: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    else:
        cursor.execute(sql_delete)
        db.commit()
    finally:
        if cursor is not None:
            cursor.close()
        if db is not None:
            db.close()
    

def fun_close():
    db.close()
    

def fun_select():
    sql_select='SELECT ip,hostname,vendor,model,type,firmware,netboxtag,mgint,mac,date FROM inventory_network WHERE error=0;'
    try:
        db = psycopg2.connect( user=dbuser,password=dbpassword, 
                      dbname=dbname,connect_timeout=20,port=dbport, host=dbip)
        cursor = db.cursor()

    except InterfaceError as e:
        print(f"\t\t\t Error connect PostgreSQL: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    else:
        cursor.execute(sql_select)
        pgnet = cursor.fetchall()
        #print(pgnet)
        return(pgnet)
    finally:
        if cursor is not None:
            cursor.close()
        if db is not None:
            db.close()
            
            
            
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    sys.argv = ['sys.argv[0]', '--ip', '10.100.27.12', '--act', 'select']
    
    parser.add_argument('--ip', '-ip', type=str, dest='ip',
                        default=ip_def, help='INPUT ipaddress')
    parser.add_argument('--act', '-act', type=str, dest='action',
                        default=act_def, help='INPUT actions')
    
    if parser.parse_args().ip: ip = parser.parse_args().ip
    if parser.parse_args().action: act = parser.parse_args().action
    
    data = [ip, 'ALBSWACCKMPZ31', 'Huawei', 'S5731_H48P4XC', 'switch', '5.170', 'netboxtag', 'Vlanif2027', '58:56:c2:bb:9d:53']
    if act == 'insert':
        fun_insert(data)
    if act == 'error':
        fun_error(ip)
    if act == 'delete':
        fun_delete()
    if act == 'select':
        fun_select()