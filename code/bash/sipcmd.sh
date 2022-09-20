#!/bin/bash
ip_src=`(ip route get 192.168.33.22 | head -n 1 | sed 's/.*src //g')`
sipcmd -u 1000 -c 12345678 -w 192.168.33.22 -P sip -l $ip_src -p 5060 -g $ip_src

