#!/bin/bash
#Скрипт для определения переменных необхадимых для отображения через X server.
#cat /etc/crontab | tail -n 1
##*/1 *   * * *   dima    /usr/bin/notify_dunst.sh Hello
#/etc/init.d/cron restart
#Для запуска посыла notify-send через dunst /mnt/1/Работа/Информ/ПК/Linux/i3/dunst.txt
message=${1:-hello}
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

init_DBUS_SESS
init_DISPLAY
init_XAUTH

#Можно и вручную, пример.
#export DISPLAY=':0'
#export XAUTHORITY='/home/dima/.Xauthority'
#export DBUS_SESSION_BUS_ADDRESS='unix:abstract=/tmp/dbus-f17bveqKyk,guid=826b1be64b7c7db990e09c1a555b7e9a'

echo $PATH | tee /tmp/env_X.txt
echo $DISPLAY | tee -a /tmp/env_X.txt
echo $XAUTHORITY | tee -a /tmp/env_X.txt
echo $DBUS_SESSION_BUS_ADDRESS | tee -a /tmp/env_X.txt

/usr/bin/notify-send -u critical "$message"
