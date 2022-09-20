#!/bin/bash
#Автозапуск окон в i3wm
if ! dpkg-query -s "xdotool" &>/dev/null; then  echo "Не установлен xdotool."; exit 1; fi
if ! dpkg-query -s "xinput" &>/dev/null; then  echo "Не установлен xinput."; exit 1; fi

[ ! "$s" = "s" ] && exit 0

#20x0.5sec=10sec ожидания.
maxwait=20

start () {
prog=$1
$prog 2>/dev/null &
#!Не выйдет с chromium,pidgin ..., так как один процесс порождает другой тот который и появляеться а иксах.
pid=$!
echo $pid
s=1
while  [ $s -le  $maxwait ]
 do
 [ "$prog" = "chromium" ] && \
  pid=`(ps -ax 2>/dev/null | grep chrom | grep -v grep  | sed 's/^ *//g' | cut -d " " -f 1 | head -n 1)`
 [ "$prog" = "snmpc32" ] && \
  pid=`(ps -ax 2>/dev/null | grep snmpc32 | grep -v grep | sed 's/^ *//g' | cut -d " " -f 1 | head -n 1)`
 [ "$prog" = "pidgin" ] && \
  pid=`(ps -ax 2>/dev/null | grep pidgin | grep -v grep | sed 's/^ *//g' | cut -d " " -f 1 | head -n 1)`
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
  sleep 0.5
 done
}


#sleep-ы нужны потому что xdotool немного раньше обнаруживает чем приложения появляються на экране.
xinput disable `(xinput --list | grep -i mouse | sed 's/.*id=\(\w*\).*/\1/g')`
i3-msg 'workspace 1'
start iceweasel
i3-msg layout stacked
start chromium

i3-msg 'workspace 2'
##xdotool getmouselocation
##yes "xdotool getmouselocation;sleep 1" | /bin/bash
start snmpc32
sleep 3
xdotool type "pfqwtdytn"
xinput enable `(xinput --list | grep -i mouse | sed 's/.*id=\(\w*\).*/\1/g')`
xdotool mousemove 910 589 && sleep 0.3 && xdotool mousedown 1 && xdotool mouseup 1
xinput disable `(xinput --list | grep -i mouse | sed 's/.*id=\(\w*\).*/\1/g')`
sleep 1
i3-msg layout tabbed
start xterm
i3-msg split v
start xterm
i3-msg resize shrink height 20 px or 20 ppt
i3-msg focus up
i3-msg split h
start xterm

i3-msg split v
i3-msg layout stacked
start xterm

i3-msg focus left
i3-msg split v
i3-msg layout stacked
start xterm

i3-msg 'workspace 3'
start xterm
i3-msg split h
start xterm
i3-msg split v
start xterm

i3-msg 'workspace 9'
start pidgin
sleep 3
#i3-msg kill
xinput enable `(xinput --list | grep -i mouse | sed 's/.*id=\(\w*\).*/\1/g')`

i3-msg 'workspace 1'

#i3-msg "floating toggle"
