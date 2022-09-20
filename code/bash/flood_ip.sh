#!/bin/bash
[ "$UID" != "0" ] && echo "No permission to perform tcpdump and nice." && exit 3
clear
int=eth2
ip link set $int promisc on
ip link set $int up
tmpfile="/tmp/flood_ip_"pid$$".txt"
tmpfile2="/tmp/flood_ip2_"pid$$".txt"
tmpfile3="/tmp/ip_flood_"pid$$".txt"

> $tmpfile
> $tmpfile2
> $tmpfile3

echo -e "\e[0;31mSTART DUMP\e[0m"
echo -e "\e[1;34m`(date)`\e[0m"
tcpdump -i $int -nnn -e -t  ether dst 00:13:c3:2b:ad:c0 and vlan 10 and dst net 0.0.0.0 and src port 0 | tee -a $tmpfile &>/dev/null &
echo -e "\e[0;32mClick key to stop tcpdump.\e[0m"
read -sn 1
kill $!
echo -e "\e[0;31mSTOP DUMP\e[0m"
echo -e "\e[1;34m`(date)`\e[0m"
nice -n -20 sed 's/^.*IPv4, \(\S*\) >.*$/\1/g' $tmpfile | sort -h | uniq -c | sed 's/..$//g' | sort -k1 -n | sed 's/^ *//g' | sed '$d' | sed '1d' | cat -n | sed 's/^ *//g' > $tmpfile2

cat $tmpfile2 | cut -f 2 -d " " > $tmpfile3



while read ip
do
clear
echo -e "\e[0;31mSTART PING\e[0m"
tput setaf 3
tput el
echo -en "$ip\n"
tput setaf 7
echo -e "\n\e[0;33m№       Amount IP icmp\e[0m"
cat $tmpfile2
ping -c 1 $ip -w 1 &>/dev/null && sed "s/$ip$/& Available/g" -i $tmpfile2 || sed "s/$ip$/& Unresponsive/g" -i $tmpfile2
done < $tmpfile3
clear
echo -e "\e[0;31mSTART PING\e[0m"
echo -e "\n\e[0;33m№       Amount IP icmp\e[0m"
cat $tmpfile2
echo -e "\n\e[0;31mSTOP PING\e[0m"


file="/root/flood_ip/`(date "+%d_%m_%y")`.txt"
mkdir -p `(dirname $file)`

echo -e "$file\n\e[0;32mSave result(Y/n)?\e[0m"
read -sn 1 key
case $key in
 [y,Y] ) cp $tmpfile2 $file;;
 [n,n] ) : ;;
  * ) : ;;
esac


> $tmpfile
> $tmpfile2
> $tmpfile3


