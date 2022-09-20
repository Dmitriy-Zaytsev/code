#!/bin/bash
#!!!Сканируеммые адреса в одной подсети с PC!!!
if [ "$UID" != "0" ]
  then
    echo "Operation not permitted";exit

  else
   if [ "$1" = "config" ]
      then
      echo \#increase max arp table
      echo net.ipv4.neigh.default.gc_thresh3 = 4096 >> /etc/sysctl.conf
      echo net.ipv4.neigh.default.gc_thresh2 = 2048 >> /etc/sysctl.conf
      echo net.ipv4.neigh.default.gc_thresh1 = 1024 >> /etc/sysctl.conf
      /sbin/sysctl -p
      exit
   fi
   if  ip route | grep -q -E "172\.19\.[0-7]\..*/21 dev eth.*\.10" && \
       ! ip route | grep -q -E "172\.19\.[0-7]\..* via"
      then  :
      else echo  "Путь к следующим адресам лежит через маршрутизатор:"
           ip route | grep -E "172\.19\.[0-7]\..* via"
   fi
echo mac to ip 172.19.0.0/21 vlan 10
echo "!!!!! ip route chan 172.19.0.0/21 dev eth1.10"
   if [ -n "$1" ]
     then
          mac=`(echo $1 | sed  -e  's/[^0-9,a-f,A-F]//g')`
          leng=`(echo -n $mac | wc -m)`
          mac=`(echo $mac | tr '[:lower:]' '[:upper:]')`
          #mac=`(echo $mac | sed -E -e 's/[." ",:;-]//g; s/[0-9,A-F][0-9,A-F]/&:/g; s/:$//')`
          ##or
          mac=`(echo $mac | sed -E -e 's/[^a-f,A-F,0-9]//g; s/[0-9,A-F][0-9,A-F]/&:/g; s/:$//')`
          if [ "$leng" != 12 ]
             then echo -e  "$leng-Недостаточное количество введёных сиволов \n $mac";exit
          fi
          echo $mac
          nmap -sP -n 172.19.0-7.0-255 > /tmp/mac_ip.txt
          num_line=`(grep -wn $mac /tmp/mac_ip.txt | cut -d : -f1)`
          if [ -n "$num_line" ]
            then cat /tmp/mac_ip.txt | head -n $num_line | tail -n 3 | sed '2d';echo Время работы сценария $SECONDS #время работы сценария. 
            exit
            else echo  mac not found; echo  Время работы сценария $SECONDS; exit
          fi
   fi
          echo -e "enter in the form of \n XX-XX-XX-XX-XX-XX \n XX:XX:XX:XX:XX:XX \n xx-xx-xx-xx-xx-xx \n xx:xx:xx:xx:xx:xx \n Xx:xx-xX:xx-XX-Xx"
fi
