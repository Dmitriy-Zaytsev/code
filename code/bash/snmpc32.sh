#!/bin/bash
startsnmpc () {
#wine /home/dima/.wine/drive_c/Program\ Files/SNMPc\ Network\ Manager/snmpc32.exe &
wine "/home/dima/.wine/drive_c/Program Files/SNMPc Network Manager/snmpc32.exe"
}

killsnmpc () {
kill -9 `(ps -ax | grep snmpc32.exe | grep -v grep | sed 's/^ *//g' | cut -f 1 -d " ")`
}

[ "$#" = "0" ] && { startsnmpc && exit 0 || exit 1;}
[ "$1" = "-r" ] && { killsnmpc && startsnmpc && exit 0 || exit 1;}
[ "$1" = "-k" ] && { killsnmpc && exit 0 || exit 1;}
