#!/usr/bin/env python3
import psycopg2

global db
db = psycopg2.connect( user='root',password='root', 
                      dbname='network',connect_timeout=20,port=5433)

db.autocommit=True

#cursor = db.cursor()
#sql="DELETE FROM inventory_network"
#cursor.execute(sql)
#cursor.close()


def fun_insert(data):
    global db
    try:
        cursor = db.cursor()
    except:
        db.close()
        db = psycopg2.connect( user='root',password='root', 
                      dbname='network',connect_timeout=20,port=5433)
        cursor = db.cursor()   
    sql_insert="INSERT INTO inventory_network(ip,vendor,model,type,firmware,hostname,ipplandesc,date,error) VALUES ('{d[0]}','{d[1]}','{d[2]}','{d[3]}','{d[4]}','{d[5]}','{d[6]}',CURRENT_TIMESTAMP,0) ON CONFLICT (ip) DO UPDATE SET vendor=EXCLUDED.vendor, model=EXCLUDED.model, firmware=EXCLUDED.firmware, type=EXCLUDED.type, hostname=EXCLUDED.hostname, ipplandesc=EXCLUDED.ipplandesc, date=EXCLUDED.date, error=EXCLUDED.error;".format(d=data)
    cursor.execute(sql_insert)
    cursor.close()

def fun_error(ip):
    global db
    try:
        cursor = db.cursor()
    except:
        db.close()
        db = psycopg2.connect( user='root',password='root', 
                      dbname='network',connect_timeout=20,port=5433)
        cursor = db.cursor()
    sql_error="UPDATE inventory_network SET error=error+1 WHERE  ip='{}';".format(ip)
    cursor.execute(sql_error)
    cursor.close()


def fun_delete():
    global db
    try:
        cursor = db.cursor()
    except:
        db.close()
        db = psycopg2.connect( user='root',password='root', 
                      dbname='network',connect_timeout=20,port=5433)
        cursor = db.cursor()
    sql_delete="DELETE FROM inventory_network WHERE error>5"
    cursor.execute(sql_delete)
    cursor.close()
    

def fun_close():
    db.close()
