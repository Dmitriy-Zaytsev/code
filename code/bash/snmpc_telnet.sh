#!/bin/bash -x
#aptitude install xinput xdotool xclip
exec &> /tmp/`(basename "$0")`_debug.txt
ip_file=/tmp/snmp_telnet.sh.csv
find $ip_file -cmin +1 -exec rm -f {} \;

fun_telnet () {
sed '/^;$/d' -i $ip_file
sed '/^$/d' -i $ip_file
sed '/^;/d' -i $ip_file
cat $ip_file | sort | uniq | sort -h -k 2 -t ";" > /tmp/snmp_telnet.file
mv /tmp/snmp_telnet.file $ip_file
splitv=0
for line in `(cat $ip_file)`
 do
  ip=`(echo $line | cut -d ";" -f 1)`
  hostname=`(echo $line | cut -d ";" -f 2)`
  xterm_snmpc  -xrm 'XTerm.vt100.allowTitleOps: false' -T "$hostname $ip" -e "tela $ip" &
  [ "$splitv" = "0" ] && { i3-msg "split v";splitv=1;}
 done
find $ip_file -exec rm -f {} \;
xdotool keyup --clearmodifiers ctrl
xdotool keyup --clearmodifiers c;xinput enable $mouse_id
xinput enable $mouse_id
exit
}

echo "" | xclip -selection clipboard -i
mouse_id=`(xinput --list | grep -i mouse | sed 's/.*id=\(\w*\).*/\1/g')`
win=`(xdotool getactivewindow)`
win_name=`(xdotool getwindowname $win)`
{ { [[ ! "$win_name" =~ "SNMPc" ]] ;} && [[ -f $ip_file ]];} && fun_telnet
{ { [[ ! "$win_name" =~ "SNMPc" ]] ;} && [[ ! -f $ip_file ]];} && { xinput enable $mouse_id; exit 20;}
xinput disable $mouse_id
xdotool mousedown 1
xdotool mouseup 1
xdotool mousedown 3
xdotool mouseup 3
sleep 0.2
mouse_location=`(xdotool getmouselocation)`
mouse_location_x=`(echo $mouse_location | sed 's/.*x:\([[:digit:]]*\).*/\1/g')`
mouse_location_y=`(echo $mouse_location | sed 's/.*y:\([[:digit:]]*\).*/\1/g')`
mouse_location_x=$(($mouse_location_x+50))
mouse_location_y=$(($mouse_location_y+10))
xdotool mousemove $mouse_location_x $mouse_location_y
sleep 0.2
xdotool mousedown 1
xdotool mouseup 1
sleep 0.2
xdotool key --clearmodifiers --window $win ctrl+c
#xdotool key --clearmodifiers ctrl+c
#xdotool keyup --clearmodifiers ctrl
#xdotool keyup --clearmodifiers c
hostname=`(xclip -selection clipboard -o)`
echo "" | xclip -selection clipboard -i
sleep 0.2
xdotool key --clearmodifiers --window $win Tab
sleep 0.2
xdotool key --clearmodifiers --window $win ctrl+c
#xdotool key --clearmodifiers ctrl+c
#xdotool keyup --clearmodifiers ctrl
#xdotool keyup --clearmodifiers c
ip=`(xclip -selection clipboard -o)`
echo "" | xclip -selection clipboard -i
echo "$ip;$hostname" >> $ip_file
[ -z "$ip" ] && { xdotool keyup --clearmodifiers ctrl;xdotool keyup --clearmodifiers c;xinput enable $mouse_id; exit 10;}
xdotool key --clearmodifiers Escape
xinput enable $mouse_id
