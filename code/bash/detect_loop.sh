#!/bin/bash
[ ! "$UID" = "0" ] && { echo "Нужны root права."; exit 1;}

fun_help () {
echo '
HELP
-q <external vlan> <internal> - qinq
-v <vlan>
-p - <type pdu> a - ARP REQUEST, p1 - PPPoE PADI, p2 - PPPoE PADO. 
-i - <interface>
-c - <count>
-r - <interval>
-w - <wait>
-T - test install packet.
-h - help
detect_loop.sh -i eth1 -q 2012 416 -w 4 -c 2 -r 2 -p a
detect_loop.sh -i eth1 -q 2012 416 -w 1 -c 3 -r 0.1 -p p
exit 0
'
}

dumpfile=/tmp/dump_`(basename $0)`_.cap

fun_packet () {
packages='
tshark
tcpdump
python
python-scapy
iproute2
lsof
'
for pack in $packages
 do
  dpkg-query -s $pack &>/dev/null || { echo "Не установлен пакет $pack" && exit 3;}
 done
}

fun_scapy () {
python - <<EOF
from scapy.all import *
print "Start phyton/scapy"


l2=Ether(src='$macpc',dst="ff:ff:ff:ff:ff:ff",type=0x8100)

if '$typepdu' == "p1":
   pdu=PPPoED(version=1,type=1,code=9,sessionid=0x0,len=4)/Raw(load='\x01\x01\x00\x00')
   pdutype = 0x8863

if '$typepdu' == "p2":
   pdu=PPPoED(version=1,type=1,code=7,sessionid=0x0,len=4)/Raw(load='\x01\x01\x00\x00')
   pdutype = 0x8863


if '$typepdu' == "a":
   pdu=ARP(hwtype=0x1,ptype=0x0800,hwlen=6,plen=4,op="who-has",hwsrc='$macpc',psrc="0.0.0.1",pdst="0.0.0.2")/Padding(load='\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')
   pdutype = 0x0806

if '$vlantype' == "qinq":
   extvlan='$extvlan'; extvlan=int(extvlan); intvlan='$intvlan'; intvlan=int(intvlan)
   vlan=Dot1Q(vlan=extvlan,type=0x8100)/Dot1Q(vlan=intvlan,type=pdutype)

if '$vlantype' == "vlan":
   vlan='$vlan';vlan=int(vlan)
   vlan=Dot1Q(vlan=vlan,type=pdutype)


PDU=l2/vlan/pdu

count='$count';count=int(count);inter='$inter';inter=float(inter)
#PDU.show()
sendp(PDU,iface='$int',count=count,inter=inter)
print "End phyton/scapy."
EOF
}

wait=1 #ждать получения.
inter="1" #интервал повторов.
count=1 #количество пакетов.
typepdu=p1
timeout=3
while getopts "q::v:t:Ti:hc:p:r:w:" Opts
  do
     case $Opts in
	q) extvlan=$OPTARG;intvlan=${!OPTIND};vlantype=qinq;((OPTIND=OPTIND+1));unset vlan;;
	t) wait=$OPTARG;;
	v) vlan=$OPTARG;vlantype=vlan;unset extvlan intvlan;;
	T) fun_packet;;
        p) typepdu=$OPTARG;;
	i) int=$OPTARG;;
	h) fun_help;;
	c) count=$OPTARG;;
	r) inter="$OPTARG";;
	w) wait=$OPTARG;;
     esac
  done


[ "$wait" -lt "2" ] && wait=2 #для запуска tcpdump нужно как минимум 2 сек.
ip link show $int &>/dev/null || unset int
[ -z "$int" ] && { echo "Выбирите интерфейс"; tshark -D 2>/dev/null; exit 1;}
macpc=`(cat /sys/class/net/$int/address)`

echo "
INTERFACE:$int EXTVLAN:$extvlan INTVLAN:$intvlan VLAN:$vlan
VLANTYPE:$vlantype TYPEPDU:$typepdu
COUNT:$count WAIT:$wait INTER:$inter
"
[ "$typepdu" = "a" -a "$vlantype" = "vlan" ] && filtertshark="(arp.opcode == 1 and (eth.src == $macpc and (eth.dst == ff:ff:ff:ff:ff:ff and (vlan.id == "$vlan"))))"
[ "$typepdu" = "a" -a "$vlantype" = "qinq" ] && filtertshark="(arp.opcode == 1 and (eth.src == $macpc and (eth.dst == ff:ff:ff:ff:ff:ff and (vlan.id == "$extvlan" and vlan.id == "$intvlan")))))"

[ "$typepdu" = "p1" -a "$vlantype" = "vlan" ] && filtertshark="(pppoe.code == 0x09 and (eth.src == $macpc and (eth.dst == ff:ff:ff:ff:ff:ff and (vlan.id == "$vlan"))))"
[ "$typepdu" = "p1" -a "$vlantype" = "qinq" ] && filtertshark="(pppoe.code == 0x09 and (eth.src == $macpc and (eth.dst == ff:ff:ff:ff:ff:ff and (vlan.id == "$extvlan" and vlan.id == "$intvlan"))))"

[ "$typepdu" = "p2" -a "$vlantype" = "vlan" ] && filtertshark="(pppoe.code == 0x07 and (eth.src == $macpc and (eth.dst == ff:ff:ff:ff:ff:ff and (vlan.id == "$vlan"))))"
[ "$typepdu" = "p2" -a "$vlantype" = "qinq" ] && filtertshark="(pppoe.code == 0x07 and (eth.src == $macpc and (eth.dst == ff:ff:ff:ff:ff:ff and (vlan.id == "$extvlan" and vlan.id == "$intvlan"))))"

if [ "$vlantype" = "qinq" ]
   then
	for var in extvlan intvlan
          do
	    [ -z "${!var}" ] && { echo "Не указана переменная $var." && exit 1;}
	  done
   elif [ "$vlantype" = "vlan" ]
        then
		[ -z "$vlan" ] && { echo "Не указана переменная vlan." && exit 1;}
else
		echo "Выбирите тип тегирования vlan/qint." && exit 1
fi



rm $dumpfile -rf
timeout "$wait" tcpdump -i "$int" -Q in -l -w $dumpfile 2>/dev/null &
fun_scapy 2>/dev/null
wait

while true
do
 lsof $dumpfile || break
done

loop=`(tshark -r $dumpfile -Y "$filtertshark" -t ud -l -c 5 2>/dev/null)`
[ -n "$loop" ] && { tput setaf 1;echo -e "\nОбнаружена петля.";ret=254;}
[ ! -n "$loop" ] && { tput setaf 2;echo -e "\nПетли нет.";ret=5;}
tput setaf 7
rm $dumpfile -rf
exit $ret
