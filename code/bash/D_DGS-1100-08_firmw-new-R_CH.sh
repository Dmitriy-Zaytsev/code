#!/bin/bash
#Смена прошивки на DGS1100-08, в начале льём через telnet потом через http.
/usr/bash_scr/mail_send.sh "СТАРТ $0"
username=admin
password=rabbit
filelog=/home/dima/DGS_firmw/ip_dgs.log
fileip=/home/dima/DGS_firmw/ip_dgs.txt
filetmp=/tmp/ip_dgs.txt
filetmp2=/tmp/ip_dgs2.txt
opcode="/srv/ftp/D_DGS-1100-08/DGS-1100-08_1.0.9_runtime.bin"


echo "Сравним ip файл уже с проделанными."

cat $fileip | sort -k1 -t" " | uniq > $filetmp
cp $filetmp $fileip
cat $filelog | grep '[^NOT] CONFIGURE'| sort -t" " -k1 | uniq | cut -f 1 -d " " > $filetmp2
cat $filetmp2 | xargs -i sed '/^{}$/d' -i $fileip

rm $filetmp
rm $filetmp2

fun_exp_reboot () {
/usr/bin/expect -c \
"
set timeout 1
send_user \n\nREBOOT\n
sleep 1
spawn /usr/bin/telnet $ip
send "$username"\n
send "$password"\n
send reboot\n
send y\n
expect "sdfsdf"
exit 6
"
ret=$?
sleep 10
echo $ret ------1
return $ret
}



fun_exp_conf () {
/usr/bin/expect -c \
"
set login 0
set i 1
set timeout 1
send_user \n\n$ip\n
sleep 1
spawn /usr/bin/telnet $ip
while { "\$i" != "4" } {
send_user \n\n\nПопытка\ \$i\n
expect Username  {send "$username"\n }
expect Password {send "$password"\n }
incr i +1
sleep 2
send \n
expect admin {set login 1;break}
}

if { "\$login" == "0"} {exit 11}

sleep 1
send \n\n
while 1 {expect admin { sleep 1; send download\ firmware_fromTFTP\ 192.168.33.13\ src_file\ D_DGS-1100-08/DGS-1100-08_1.0.9_runtime.bin\n ; break}}

set x 30
while { "\$x" != "0" } {
 send_user До\ продолжения\ осталось
 send_user \ \$x\ секунд\r
 incr x -1
 expect closed { send_user \n;break}
}
expect "sdfsdf"
exit 5
"
ret=$?
[ "$ret" = "5" ] && { echo CURL_START && /usr/bin/curl -F uploadfiled=@$opcode  -F submit=OK http://$ip/FUpdate.cgi -v &>/dev/null && echo CURL_STOP && return $ret;}
return 1
}

while read ip
do
ping $ip -W 1 -c 1 &>/dev/null || { echo "$ip - NOT ICMP." | tee -a $filelog && sleep 2 && continue;}
nmap -n -p 23 $ip -Pn | grep -i '23.*open' &>/dev/null || { echo "$ip - NOT TELNET." | tee -a $filelog && sleep 2 && continue;}
fun_exp_conf
ret=$?
if [ "$ret" = "5" ]
  then
     echo "$ip - CONFIGURE." | tee -a "$filelog"
  else
     fun_exp_reboot
     ret=$?
     if [ "$ret" = "6" ]
       then
          echo "$ip - REBOOT." | tee -a "$filelog"
          fun_exp_conf
          [ "$ret" = "5" ] && echo "$ip - CONFIGURE." | tee -a "$filelog"
          [ ! "$ret" = "5" ] && echo "$ip - NOT CONFIGURE." | tee -a "$filelog"
        else
         echo "$ip - NO REBOOT." | tee -a "$filelog"
      fi
fi
done  < $fileip
/usr/bash_scr/mail_send.sh "STOP $0"
