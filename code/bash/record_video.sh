#!/bin/bash
dpkg -s recordmydesktop &> /dev/null || { echo "Не установлен recordmydesktop" && exit 1;}
file=${1:-video}
test -f ./$file.ogv && { echo "Фйал существует" && exit 1;}
recordmydesktop --no-sound --v_quality 63 --v_bitrate 2000000 --fps 60 --delay 4 --pause-shortcut Shift+p --stop-shortcut Shift+s -o ./$file.ogv
xterm -e dialog --msgbox "recordmydesktop:\n$file.ovg completed" 10 30
exit 0
