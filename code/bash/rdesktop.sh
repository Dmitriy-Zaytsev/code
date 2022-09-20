#!/bin/bash
ip=192.168.33.17
port="3389"
user="kos"
password="rabbit"
dir="/mnt/hdd/"


packages_inst='
libxrandr2:amd64
rdesktop
'

for package in $packages_inst
do
 ! dpkg-query -s "$package" &>/dev/null &&  { echo "Не установлен $package."; exit 2;}
done

screen_size=`(xrandr  | grep \* | sed 's/.* \([[:digit:]]*x[[:digit:]]*\) .*/\1/g')`


rdesktop $ip:$port -u $user -p $password -r disk:share=$dir -g $screen_size
