#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DB_FILE=~/.kodi/userdata/Database/TV29.db
IPTV=~/iptv.m3u8

UNIQID_PVR=$(echo "$1" | grep -o '[0-9]*');
# UNIQID_PVR соответствует записи iUniqueId в таблице channels базы TV30.db


NSTR_PVR=$(grep -n "$(echo "SELECT sChannelName FROM channels WHERE iUniqueId = $UNIQID_PVR;" | sqlite3 $DB_FILE)" $IPTV | cut -d: -f1);
# NSTR_PVR это номер строки в файле iptv.m3u.cache, соответствует имени канала (sChannelName) в таблице channels базы TV30.db


UPDATE_PVR=$(echo "UPDATE channels SET iLastWatched =  `date +%s` WHERE iUniqueId = $UNIQID_PVR;" | sqlite3 $DB_FILE);
echo $UPDATE_PVR # Пишем в базу (TV30.db) время начала просмотра  канала (iLastWatched)

DISPLAY=:0 mpv --volume=0 $(awk "NR==$NSTR_PVR+1 { print}" $IPTV);
