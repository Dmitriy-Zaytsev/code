#!/bin/bash
#Скрипт для определения переменных необхадимых для отображения через X server,если запущенна не через X-ы с консоли.
#cat /etc/crontab
#24 17   30 * * dima  /usr/bin/notify.sh "SberBank" "critical" "/usr/share/icons/money.png" &>/dev/null
#Для запуска посыла notify-send через dunst /mnt/1/Работа/Информ/ПК/Linux/i3/dunst.txt
packages='
i3-wm
dunst
libnotify-bin
libnotify4
'

for pack in $packages
do
dpkg-query -s $pack &>/dev/null || { echo "$pack не установлен."; exit 1;}
done


[ pgrep dunst 2>&1 >/dev/null] || nohup dunst &>/dev/null &

message=${1:-hello}
urgency=${2:-low}
icon=$3
time=${4:-0}
init_DBUS_SESS ()
{
user=`whoami`
pids=`pgrep -u $user`
    for pid in $pids; do
        DBUS_SESSION_BUS_ADDRESS=`grep -z DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ | sed -e 's/DBUS_SESSION_BUS_ADDRESS=//'`
        #env > /tmp/var
        export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS
        [ ! -z "$DBUS_SESSION_BUS_ADDRESS" ] && break
    done
}

init_DISPLAY ()
{
export DISPLAY=`(ps -axu 2>/dev/null | grep $(whoami) | grep X | grep -v grep | sed 's/.*\(:\S\).*/\1/g')`
}

init_XAUTH ()
{
XAUTHORITY=/home/`(whoami)`/.Xauthority
}

#Обнуляем переменные для X-ов.
DISPLAY=;
XAUTHORITY=;
DBUS_SESSION_BUS_ADDRESS=;

init_DISPLAY
if [ -z "$DISPLAY" ]
 then
    wall $message
 else
init_DBUS_SESS
init_XAUTH
#Можно и вручную, пример.
#export DISPLAY=':0'
#export XAUTHORITY='/home/dima/.Xauthority'
#export DBUS_SESSION_BUS_ADDRESS='unix:abstract=/tmp/dbus-f17bveqKyk,guid=826b1be64b7c7db990e09c1a555b7e9a'

export PATH
export DISPLAY
export XAUTHORITY
export DBUS_SESSION_BUS_ADDRESS
echo '----------------------------------'
echo PATH $PATH | tee /tmp/env_X.txt
echo DISPLAY $DISPLAY | tee -a /tmp/env_X.txt
echo XAUTHORITY $XAUTHORITY | tee -a /tmp/env_X.txt
echo DBUS_SESSION_BUS_ADDRESS $DBUS_SESSION_BUS_ADDRESS | tee -a /tmp/env_X.txt
echo '----------------------------------'


/usr/bin/notify-send -u "$urgency" "$message" ${icon:+ -i "$icon"} -t $time
fi
