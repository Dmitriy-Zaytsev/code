#!/bin/bash
m3u8='http://35a70d2e.iptvbot.biz/iptv/BY4XCEV4UZM3G3/237/index.m3u8'
repeat='3'
sysctl -a > /tmp/sysctl.conf.backup

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

for congestion in $(ls /lib/modules/`(uname -r)`/kernel/net/ipv4/tcp_* | sed 's/.*\/\(.*\).ko/\1/g' | tr ' ' '\n')
do
modprobe $congestion 2>/dev/null
done

file=`(wget --timeout=2 -O- $m3u8 2>/dev/null | tail -n 1)`
for congestion in $(sysctl net.ipv4.tcp_available_congestion_control -n | sed 's/ /\n/g')
do
echo "${congestion#tcp_*}" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null || continue
sysctl -w net.ipv4.route.flush=1 &>/dev/null
sleep 1
echo -e "\nTCP_CONGESTION $congestion"
echo "CURRENT CONGESTION `(sysctl net.ipv4.tcp_congestion_control)`"
sysctl -w net.ipv4.route.flush=1 &>/dev/null
for n in `(seq 1 $repeat)`
do
echo -n "$n: "
curl -Lo /dev/null -skw "remote_ip: %{remote_ip} time_namelookup: %{time_namelookup}s\ntime_pretransfer: %{time_pretransfer} time_starttransfer: %{time_starttransfer}s time_redirect: %{time_redirect}s\ntime_total: %{time_total}s size_download: %{size_download}B speed_download: %{speed_download}B/s\n" "$file"
done
done
echo -e "\n------------\n"
#done
sysctl -p /tmp/sysctl.conf.backup &>/dev/null

