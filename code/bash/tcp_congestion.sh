#!/bin/bash
server='
1325
4963
2703
'
repeat='1'

sysctl -w net.ipv4.tcp_sack=1 &>/dev/null
sysctl -w net.ipv4.tcp_timestamps=1 &>/dev/null
sysctl -w net.ipv4.tcp_window_scaling=1 &>/dev/null

sysctl -w net.ipv4.tcp_sack=1 &>/dev/null

sysctl -w net.ipv4.route.flush=1 &>/dev/null
sysctl -w net.ipv4.tcp_no_metrics_save=1 &>/dev/null

sysctl -w net.core.netdev_max_backlog=2500 &>/dev/null

sysctl -w net.core.rmem_max=33554432 &>/dev/null
sysctl -w net.core.wmem_max=33554432 &>/dev/null
sysctl -w net.ipv4.tcp_rmem="4096 87380 33554432" &>/dev/null
sysctl -w net.ipv4.tcp_wmem="4096 87380 33554432" &>/dev/null

sysctl net.core.rmem_default=65536 &>/dev/null
sysctl net.core.wmem_default=65536 &>/dev/null

sysctl -w net.ipv4.tcp_base_mss=1440 &>/dev/null


#for ser in $server
#do
#speedtest-cli --list | grep "$ser)" | cut -f 2-99 -d " "
for congestion in $(ls /lib/modules/`(uname -r)`/kernel/net/ipv4/tcp_* | sed 's/.*\/\(.*\).ko/\1/g' | tr ' ' '\n')
do
modprobe $congestion
echo "${congestion#tcp_*}" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null || continue
sysctl -w net.ipv4.route.flush=1 &>/dev/null
sleep 1
echo -e "\nTCP_CONGESTION $congestion"
echo "CURRENT CONGESTION `(sysctl net.ipv4.tcp_congestion_control)`"
for n in `(seq 1 $repeat)`
do
echo -n "$n: "
#speedtest-cli --server $ser | grep -E "Download|Upload" | sed 's/Download/D/g' | sed 's/Upload/U/g' | tr '\n' ' '
#wget  http://speedtest.wdc01.softlayer.com/downloads/test500.zip 2>&1 | grep -o "[0-9.]\+ [KM]*B/s"
wget  http://speedtest.wdc01.softlayer.com/downloads/test100.zip 2>&1 | grep -o "=[0-9ms,.]*\|[0-9.]\+ [KM]*B/s" | tr "\n" " " | tr -d "="
rm ./test100.zip 2>/dev/null
done
done
echo -e "\n------------\n"
#done
