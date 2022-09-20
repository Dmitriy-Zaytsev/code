#!/bin/bash
exec >/tmp/eve-ng.log

fun_telnet () {
echo telnet
echo $@
ip=`(echo "$@" | cut -d "/" -f 3 | cut -d ":" -f 1)`
port=`(echo "$@" | cut -d ":" -f 3)`
xterm_eveng -xrm "XTerm.vt100.allowTitleOps: false" -T "$ip" -e "telnet $ip $port"
}

fun_capture () {
echo capture
ip=`(echo $@ | cut -d "/" -f 3)`
interface=`(echo $@ | cut -d "/" -f 4)`
echo $@
echo $interface
ssh root@$ip "tcpdump -i $interface -U -w -" | wireshark -k -i -
}
echo $ip $port
fun_vnc () {
echo vnc
ip=`(echo "$@" | cut -d "/" -f 3 | cut -d ":" -f 1)`
port=`(echo "$@" | cut -d ":" -f 3)`
xvncviewer $ip:$port
}

action=`(echo $@ | cut -d ':' -f 1)`
case $action in
 telnet) fun_telnet $@;;
 capture) fun_capture $@;;
 vnc) fun_vnc $@;;
 * ) echo "No def func";;
esac
