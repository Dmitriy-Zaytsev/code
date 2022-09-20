#!/bin/bash
set -x
exec 1>/tmp/eve-ng.sh.log 2>&1

echo $@

fun_telnet () {
echo telnet
ip=`(echo "$@" | cut -d "/" -f 3 | cut -d ":" -f 1)`
port=`(echo "$@" | cut -d ":" -f 3)`
xterm_eveng -xrm "XTerm.vt100.allowTitleOps: false" -T "$ip" -e "telnet $ip $port"
}

fun_capture () {
echo capture
ip=`(echo $@ | cut -d "/" -f 3)`
interface=`(echo $@ | cut -d "/" -f 4)`
ssh -o StrictHostKeyChecking=no root@$ip "tcpdump -i $interface -U -w -" | wireshark_eveng  -k -i -
#wireshark_eveng -k -i <(ssh -o StrictHostKeyChecking=no root@$ip -p $port 'tcpdump -i '"$interface"' -U -w -')
}

fun_vnc () {
echo vnc
ip=`(echo "$@" | cut -d "/" -f 3 | cut -d ":" -f 1)`
port=`(echo "$@" | cut -d ":" -f 3)`
xvncviewer_eveng $ip:$port
}

action=`(echo $@ | cut -d ':' -f 1)`
case $action in
 telnet) fun_telnet $@;;
 capture) fun_capture $@;;
 vnc) fun_vnc $@;;
 * ) echo "No def func";;
esac
