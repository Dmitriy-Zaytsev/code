#!/bin/bash

for ip in `(echo 192.168.33.{120..254})`
 do
   echo $ip
   sysname=`(snmpget -c ghbitktw -v 2c $ip -t 1 -r 0 sysName.0 -Oqv 2>/dev/null | grep tbt)`
   [ -z "$sysname" ] && continue
   ./Change_prompt-sysname.exp $ip
 done
