#!/bin/bash
while true
do
 ping 8.8.8.8 -c 1 -w 2 -s 40 &> /dev/null && zenity --info --text="WAN access" && exit 0
done
