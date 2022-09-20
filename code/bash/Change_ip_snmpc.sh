#!/bin/bash
IP_OLD="${1%%/*}"
IP_NEW="${2%%/*}"
MODEL="$3"
debug=on
fun_debug () {
[ "$debug" = "on" ] || return 0
echo $1
sleep 2
}

fun_disable () {
xinput disable `(xinput --list | grep -i "Chicony HP Elite USB Keyboard" | sed 's/.*id=\(\w*\).*/\1/g' | tail -n 1)`
xinput disable `(xinput --list | grep -i mouse | sed 's/.*id=\(\w*\).*/\1/g')`
}

fun_enable () {
xinput enable `(xinput --list | grep -i "Chicony HP Elite USB Keyboard" | sed 's/.*id=\(\w*\).*/\1/g' | tail -n 1)`
xinput enable `(xinput --list | grep -i mouse | sed 's/.*id=\(\w*\).*/\1/g')`
}

echo "$IP_OLD->$IP_NEW MODEL:$MODEL"

#: () {
fun_disable
xdotool mousemove 550 726
fun_debug "CANCEL"
xdotool mousedown 1;xdotool mouseup 1
i3-msg 'workspace 3'
#find
xdotool mousemove 18 52
fun_debug "FIND"
xdotool mousedown 1
xdotool mouseup 1
#find stop
xdotool mousemove 422 487
fun_debug "FIND STOP"
xdotool mousedown 1
xdotool mouseup 1
#address
xdotool mousemove 363 299
fun_debug "ADDRESS"
xdotool mousedown 1
xdotool mouseup 1
#value
xdotool mousemove 500 185
fun_debug "VALUE"
xdotool mousedown 1
xdotool mouseup 1
xdotool mousedown 1
xdotool mouseup 1
xdotool type "$IP_OLD"
#find start
xdotool mousemove 360 489
fun_debug "FIND START"
xdotool mousedown 1
xdotool mouseup 1
fun_enable
sleep 2
#check result
i=0
while true
 do
  fun_disable
  xdotool mousedown 1;xdotool mouseup 1
  grabc &> /tmp/grabc_color.txt &
  sleep 0.5
  fun_debug "CHECK RESULT"
  xdotool mousemove 350 91
  xdotool mousedown 1
  xdotool mouseup 1
  cat /tmp/grabc_color.txt | grep "10,36,106" --color && { fun_enable;break;}
  cat /tmp/grabc_color.txt | grep "212,208,200" --color && { fun_enable;break;}
  fun_enable
  echo "ENABLE KEY MOUSE"
  sleep 3
  ((i=$i+1))
  if [ "$i" = "30" ]
    then
      fun_enable
      #find stop
      xdotool mousemove 422 487
      fun_debug "FIND STOP"
      xdotool mousedown 1
      xdotool mouseup 1
      exit 1
 fi
 done
#}
fun_disable
#context menu
xdotool mousemove 350 91
fun_debug "CONTEXT MENU"
xdotool mousedown 3
xdotool mouseup 3
#properties
xdotool mousemove 390 105
fun_debug "PROPERTIES"
xdotool mousedown 1
xdotool mouseup 1
#address
xdotool mousemove 466 421
fun_debug "ADDRESS"
xdotool mousedown 1;xdotool mouseup 1
xdotool mousedown 1;xdotool mouseup 1
sleep 0.8
xdotool key --delay 0 ctrl+c
if xclip -selection clipboard -o | grep "^$IP_OLD$" &>/dev/null
  then
     :
  else
     xdotool mousemove 550 726
     fun_debug "CANCEL"
     xdotool mousedown 1;xdotool mouseup 1
     fun_enable
     echo "ERROR SELECT OBJECT"
     exit 1
fi

xdotool type "$IP_NEW"

xdotool mousedown 1;xdotool mouseup 1
xdotool mousedown 1;xdotool mouseup 1
sleep 0.8
xdotool key --delay 0 ctrl+c
if xclip -selection clipboard -o | grep "^$IP_NEW$" &>/dev/null
  then
     :
  else
     xdotool mousemove 550 726
     fun_debug "CANCEL"
     xdotool mousedown 1;xdotool mouseup 1
     fun_enable
     echo "ERROR SELECT OBJECT"
     exit 1
fi
#description
xdotool mousemove 488 625
fun_debug "DESCRIPTION"
xdotool mousedown 1;xdotool mousemove 296 545;xdotool mouseup 1
xdotool key --delay 0 ctrl+c
description=`(xclip -selection clipboard -o)`
if [ "$description" = "$MODEL" ]
  then
      :
  else
    xdotool type "$MODEL $description"
fi
#ok
xdotool mousemove 472 726
fun_debug "OK"
xdotool mousedown 1;xdotool mouseup 1
fun_enable
