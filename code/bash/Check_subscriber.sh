#!/bin/bash
subscriber=31013156327
#subscriber=speedtest
time=5
PATH=$PATH:/usr/bash_scr

INET=1
while true
 do
  sleep $time
  uptime=`(snmpwalk -c kp2x45dv8v -v 2c 192.168.32.2 .1.3.6.1.4.1.2352.2.27.1.1.1.1.5.\"$subscriber\" -Oaqv 2>/dev/null | grep -v "No Such Instance")`
echo $uptime
  if [ -z "$uptime" ]
     then
	 echo "$subscriber auth no."
         [ "$INET" = "0" ] && continue
         echo "send mail..."
	 echo "Пропал интернет." | mail_send_mts.sh shnufik18.07.87@gmail.com "$subscriber"
 	 INET=0
     else
	 echo "$subscriber auth yes."
         [ "$INET" = "1" ] && continue
	 echo "Появился интернет." | mail_send_mts.sh shnufik18.07.87@gmail.com "$subscriber"
	 INET=1
  fi
 done

