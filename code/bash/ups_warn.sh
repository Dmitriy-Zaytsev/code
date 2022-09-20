#!/bin/bash
ip='172.19.12.'
communityR='ghbitktw'
tmpfile=`(mktemp)` #для ip.
tmpfile2=`(mktemp)` #для tmp ip.
tmpfile3=`(mktemp)` #для ip о которых мы предупреждали.
num_check=0
num_check_max=900
start_oct=2
end_oct=128

echo tmpfile $tmpfile
echo tmpfile2 $tmpfile2
echo tmpfile3 $tmpfile3

export DISPLAY=:0
export XAUTHORITY=/home/dima/.Xauthority
DBUS_SESSION_BUS_ADDRESS=;
log="/var/log/detect_def_sw.log"

funcXser ()
{
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



#SCAN UPS
fun_scan_ups () {
funcXser && init_notif
echo  -e "\n --- \nRUN FUNC $FUNCNAME"
> $tmpfile2
for oct in `(seq $start_oct $end_oct)`
 do
  ip_addr="$ip$oct"
  echo SCAN $ip_addr
  ping -l 2 -c 2 -W 2 $ip_addr  &>/dev/null && \
   [ "\"Delta\"" = "`(snmpget -c $communityR -v 1 $ip_addr  enterprises.2254.2.4.1.1.0 -t 1 -r 1 -Onqv 2>/dev/null)`" ] && echo $ip_addr >> $tmpfile2
 done
cat $tmpfile2 $tmpfile3 | sort -k1 | uniq 2>/dev/null > $tmpfile
echo TMPFILE IP START.
cat $tmpfile
echo TMPFILE IP END.
echo -e "STOP FUNC $FUNCNAME\n ---\n"
}
#SPEAK
fun_speak () {
echo $ip_ups 2222

if [ "$1" = "alarm" ]
   then
    echo -e "+\n+\n+\n+ALARM\n+\n+\n+"
    notify-send -u critical "$ip_ups status $status" -t 300000
    mpg123 /usr/share/sounds/mario/mario_end.mp3 &>/dev/null &
   elif [ "$1" = "noalarm" ]
     then
       notify-send -u critical "$ip_ups status $status" -t 300000
       echo -e "+\n+\n+\nNOALARM\n+\n+\n+"
       mpg123 /usr/share/sounds/mario/mario_start.mp3 &>/dev/null &
fi
}

#CHECK STATUS
fun_scan_ups
while true
 do
  OLDIFS=$IFS
  IFS=$'\n'
  for ip_ups in `(cat $tmpfile)`
  do
   IFS=$OLDIFS
   echo -e "\n\nIP_UPS - $ip_ups"
   status=`(snmpget -v 1 -c $communityR $ip_ups UPS-MIB::upsOutputSource.0 -Onqv 2>/dev/null)`
    echo STATUS $status
    echo $ip_ups 1111
    export ip_ups

   if [[ "$status" = "battery" ]] || ! ping -l 2 -c 2 -W 2 $ip_ups &>/dev/null
    then
     echo "UPS-$ip_ups в режиме от батареи или нет ответа ping."
    ! grep $ip_ups $tmpfile3 &>/dev/null && fun_speak alarm
     echo $ip_ups >> $tmpfile3
    else
     grep $ip_ups $tmpfile3 &>/dev/null && fun_speak noalarm
     sed -E "/^$ip_ups$/d" -i $tmpfile3
   fi
  done
  ((num_check=$num_check+1))
  echo " --- LOOP NUM  $num_check ---"
   [ "$num_check" = "$num_check_max" ] && num_check=0 && fun_scan_ups
 done

#rm $tmpfile
echo $tmpfile
