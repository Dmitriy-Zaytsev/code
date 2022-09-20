#!/bin/bash
[ ! "$#" = "1" ] && echo "Specify the interface." && exit
! dpkg-query -s "zenity" &>/dev/null && echo "Не установлен zenity." && exit
[ ! "$UID" = "0" ] && echo "Not privilege." && exit

fun ()
{
scan=$(iwlist $1 scan | grep -E -v "IE:\ Unknown|Mb/s|Extra|Mode:|Scan\ completed" | \
 sed -E -e 's/.*Cell.*-\ |//g' -e 's/\ \ \ //g' -e 's/^\  //g' | \
 sed -E -e 's/Address.*/---\n&/g' | sed -E -e '1, /---/d' | tr '\n' ' ' | \
 sed -E 's/ /^/g' | sed -e 's/---./\n/g' | \
 sed -E -e 's/.*Address\:\^(.*)\^Channel\:(.*)\^Frequency:(.*GHz)\^.*Quality=(.*)\^.Signal\^level=-(.*dBm)\^.*ESSID:"(.*)".*(IE.*$)/"" \6 \1 \2 \3 \4 \5 \7/g')

zenity --list --radiolist \
 --title="LIST" --text="Выберите wifi-ac..." \
 --column=№ --column="ESSID"  --column="MAC" --column="Channel" --column="Frequency" --column="Quality" --column="Signal level -" --column="Encryption/Authentication" \
 $scan\
 --cancel-label="Return" --ok-label="OK" \
 --print-column=2 \
 --cancel-label="Return" --ok-label="OK" \
 --width 800 --height 400
 [ ! "$?" = "0" ] && fun || exit
}

fun
