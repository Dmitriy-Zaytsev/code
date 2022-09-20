#!/bin/bash
echo $@ > /tmp/`(basename $0)`_var.log
ip=`(echo $@ | sed 's/.*\/\/\(.*\)\/\(.*\)/\1/g')`
interface=`(echo $@ | sed 's/.*\/\/\(.*\)\/\(.*\)/\2/g')`
port=22
wireshark -k -i <(ssh root@$ip -p $port 'tcpdump -i '"$interface"' -U -w -')
