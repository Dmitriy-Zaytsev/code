#!/bin/bash
#install  libnotify-bin and dunst
#dunst &
#and ...

#Если мы запусти скрипт до запуска X-oв, при запуске X-ов
#переменная $DISPLAY не перечитается, и скрипт будет думать что
#Xserver не запущен.
#DISPLAY=:0
#XAUTHORITY=/home/dima/.Xauthority

export DISPLAY=:0
export XAUTHORITY=/home/dima/.Xauthority
DBUS_SESSION_BUS_ADDRESS=;
log="/var/log/detect_def_sw.log"


funcXser ()
{
#Нам этот вриант не подходит, так как переменная будет получена от родительского процесса до запуска X-ов.
#if [ -z "$DISPLAY" ]
#  then return 1 #Нет X-oв.
#  else return 0 #X-ы запущены.
#fi
ps -ax  | grep X | grep -E -v "grep|xinit" && return 0
return 1
}

init_notif ()
{
user=`whoami`
pids=`pgrep -u $user`
    for pid in $pids; do
        DBUS_SESSION_BUS_ADDRESS=`grep -z DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ | sed -e 's/DBUS_SESSION_BUS_ADDRESS=//'`
        #echo $pid
        #echo $DISPLAY $XAUTHORITY $DBUS_SESSION_BUS_ADDRESS | tee -a /tmp/X
        env > /tmp/var
        export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS
        [ ! -z "$DBUS_SESSION_BUS_ADDRESS" ] && break
    done
}


func ()
{
[ "$1" = "xser" -a -z "$DBUS_SESSION_BUS_ADDRESS" ] && \
init_notif
case $i in
172.19.4.254 )  echo "EDGE-CORE DETECT" ;;
172.19.5.254 )  echo "DGS 1108-08 DETECT";;
172.19.7.254 )  echo "DES 1210-28ME DETECT";;
172.19.6.254 )  echo "DES-3200-10 DETECT";;
esac
}

while true
do
 for i in 172.19.4.254 172.19.5.254 172.19.7.254 172.19.6.254
  do
   # echo $DISPLAY $XAUTHORITY $DBUS_SESSION_BUS_ADDRESS
   ping $i -c 1 -W 1 && \
   { funcXser && func xser | xargs -i notify-send -t 1 -i /usr/share/icons/gnome/32x32/apps/preferences-desktop-keyboard.png -u low {} || func | xargs -i echo "`(date "+%d/%m/%y %H:%M:%S:%N")`---{}" >> $log ;}
   # { funcXser && { func xser && zenity --info 20 20;} || func | xargs -i echo "`(date "+%d/%m/%y %H:%M:%S:%N")`---{}" >> /home/dima/detect_def_sw.log ;}
  done
done
