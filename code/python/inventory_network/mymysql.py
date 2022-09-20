#!/usr/bin/env python3
import mysql.connector

dbnet = mysql.connector.connect(user='root', 
                              password='',
                              host='127.0.0.1',
                              unix_socket='/var/run/mysqld/mysqld.sock', 
                              database='network',
                              connection_timeout=1080000)

cursor = dbnet.cursor(buffered=True)
def fun_open():
    dbnet.connect()

def fun_insert(data):
    fun_open()
    sql_insert="REPLACE INTO inventory_network(ip,vendor,model,firmware,hostname,date,error) VALUE (inet_aton('{d[0]}'),'{d[1]}','{d[2]}','{d[3]}','{d[4]}',current_timestamp(),{d[5]} );".format(d=data)
    cursor.execute(sql_insert)
    fun_commit()
    fun_close()

def fun_error(ip):
    fun_open()
    sql_error="UPDATE inventory_network SET error=error+1 WHERE  ip=inet_aton('{}');".format(ip)
    cursor.execute(sql_error)
    fun_commit()
    fun_close()

def fun_delete():
    fun_open()
    sql_delete="DELETE FROM inventory_network WHERE error>5"
    cursor.execute(sql_delete)
    fun_commit()
    fun_close()
    
def fun_commit():
    dbnet.commit()

def fun_close():
    dbnet.close()
