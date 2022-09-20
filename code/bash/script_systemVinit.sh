#!/bin/bash
### BEGIN INIT INFO
# Provides:           detect_sw
# Required-Start:     $all
# Required-Stop:      $all
# Default-Start:     2
# Default-Stop:      0 1 6
# Short-Description: Running /usr/bin/detect_def_sw_notif.sh
### END INIT INFO

[ ! "$UID" = "0" ] && echo "Not privilege." && exit

. /lib/lsb/init-functions

script="/usr/bin/detect_def_sw_notif.sh"
pid="/var/run/detect_sw.pid"

#func () {
#log_daemon_msg "Script $script not found."
#log_end_msg 1
#return 0
#}
#test -x "$script" || { func && exit 1;}
#OR
test -x "$script" || log_failure_msg "Script $script not found."

case "$1" in
     start ) log_daemon_msg "Start scritp `(basename $script)`" || true;
            if [ -e $pid ]
              then log_end_msg 1; log_action_msg "Script already running."
              elif start-stop-daemon -c 1000 -S -q -b -m -p $pid -x $script 2>/dev/null
                  then log_end_msg 0 || true
                  else log_end_msg 1 || true
            fi;;
     stop ) log_daemon_msg "Stop scritp `(basename $script)`" || true;
            if [ ! -e $pid ]
              then log_end_msg 1; log_action_msg "Script not running."
              elif start-stop-daemon -c 1000 -K -o -q -p $pid 2>/dev/null
                  then rm  $pid
                       log_end_msg 0 || true
                  else log_end_msg 1 || true
            fi;;
   reload ) log_action_msg "Reload scritp `(basename $script)`" || true;
            $0 stop
            $0 start;;
   status ) start-stop-daemon -T -p $pid 2>/dev/null \
           && log_action_msg "$script is running" || log_action_msg "$script is not running";;
        * ) log_action_msg "Usage: $script {start|stop|reload|status}";;

esac
