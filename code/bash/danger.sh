#!/bin/bash
if ! dpkg-query -s "xdotool" &>/dev/null; then  echo "Не установлен xdotool."; exit 1; fi
#if ! dpkg-query -s "mpv" &>/dev/null; then  echo "Не установлен mpv."; exit 1; fi
if ! dpkg-query -s "smplayer" &>/dev/null; then  echo "Не установлен smplayer."; exit 1; fi


video_file='/mnt/hdd/video/Компьютерные_сети_ч.2.mp4'
#video_file='/mnt/hdd/video/Компьютерные_сети_ч.2_low_quality.mp4'
maxwait=70
nice='nice -n -20'

start () {
prog="$1"
$nice $prog >/dev/null &
#!Не выйдет с chromium,pidgin ..., так как один процесс порождает другой тот который и появляеться а иксах.Или если запустить xterm c -e.
pid=$!
echo $pid
s=1
while  [ $s -le  $maxwait ]
 do
 [[ "$prog" =~ "mpv" ]] && \
  pid=`(ps -ax 2>/dev/null | grep mpv | grep -v grep  | sed 's/^ *//g' | cut -d " " -f 1 | head -n 1)`
#Если окно процесса в данный момент видна.
 if xdotool search --onlyvisible --pid $pid
 #if xdotool search --class $prog
  then
    echo ""$prog" pid "$pid" Запустилась в иксаХ"
    return 0
   else
    echo ""$prog" pid "$pid" Нет запуска в иксаХ."
  fi
  echo $s
  ((s=s+1))
  sleep 0.2
 done
}

xset s activate
i3-msg 'workspace 11'
#ps -ax | grep -v grep | grep "mpv $video_file" ||  start "mpv "$video_file" --start=1:00:00 --border=no  --volume=100"
ps -ax | grep -v grep | grep "smplayer $video_file" && smplayer -send-action pause ||  start "smplayer "$video_file""
xset s activate
killall chromium &
killall mocp &
i3-msg split v
xset s reset
#start 'xterm -e telnet 172.19.0.1'
i3-msg resize shrink height 20 px or 20 ppt
i3-msg focus down
i3-msg 'bar hidden_state toggle'
i3-msg 'bar mode hide'
#i3-msg 'bar mode dock'

