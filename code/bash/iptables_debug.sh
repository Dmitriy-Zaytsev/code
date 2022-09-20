#!/bin/bash
echo -e "Скрипт для добавления правил отслеживания цепочек/таблицы iptables(по icmp type 0 и 8(ping)).\n$0 add добавит правила и изменит rsyslog.conf.\n$0 del обратит изменения.\nЛог файл в /var/log/iptables.log"
read -n 1 -p "Продолжить(y/N)" key
[ ! "$key" = "y" ] && exit 2
ipt="/sbin/iptables"
iptables_chain_and_tabl="
\
INPUT -t nat
OUTPUT -t nat
PREROUTING -t nat
POSTROUTING -t nat
\
PREROUTING -t mangle
INPUT -t mangle
FORWARD -t mangle
OUTPUT -t mangle
POSTROUTING -t mangle
\
INPUT -t filter
FORWARD -t filter
OUTPUT -t filter
\
PREROUTING -t raw
OUTPUT -t raw
"
iptables_match="
-p icmp --icmp-type 8
-p icmp --icmp-type 0
"
perfix="IPTAB"
iptables_log="-j LOG --log-prefix \"$perfix:"


#Для добавления в /etc/rsyslog.conf
rsyslog_string_1="\$template format_iptables,\"%msg%\\\n\""
rsyslog_string_2=":msg,contains, \"$perfix: \" -\/var\/log\/iptables.log;format_iptables"
rsyslog_string_3="& ~"
rsyslog_string="$rsyslog_string_1\n$rsyslog_string_2\n$rsyslog_string_3\n"
#rsyslog_string="$template format_iptables,\"%msg%\\n\":msg,contains, \"$perfix: \" -\/var\/log\/iptables.log;format_iptables\n& ~"

backup_iptables="/tmp/iptables.rules.backup"
backup_rsyslog="/tmp/rsyslog.conf.backup"


fun_iptables () {
act=;
#-A добавит в конец, если мы не видим пакет в какой либо цепочке значит на него применилось другое правило(-j ACCEPT) и он ушёл дальше, либо по контракту.
[ "$1" = "add" ] && act='-I'
[ "$1" = "del" ] && act='-D'
[ -z "$1" ] && { echo "Не определено действие для iptables." && exit 1;}
#Для того что бы for считал следующие слово после переноса строки.
OLDIFS=$IFS
IFS=$'\n'
for table_chain in $iptables_chain_and_tabl
 do
  for match in $iptables_match
   do
     log_all="$iptables_log $table_chain:\""
     command="$ipt $act $table_chain $match $log_all"
     #$command #работать не будет так как IFS у нас изменено.
     echo $command | /bin/bash - && echo -e "Применено правило "$command"\n"
   done
 done
IFS=$OLDIFS

}


fun_config () {
act=$1
echo -e "BACKUP file: \nrsyslog -> $backup_rsyslog \niptables -> $backup_iptables"
if [ "$act" = "add" ]
 then
  cp /etc/rsyslog.conf $backup_rsyslog
  iptables-save > $backup_iptables
  echo "Изменение в конфиге rsyslogd /etc/rsyslog.conf."
  sed -E "/^[^\#].*\/var\/log\/syslog/ i $rsyslog_string" /etc/rsyslog.conf -i
  /etc/init.d/rsyslog restart
 elif [ "$act" = "del" ]
    then
     cp $backup_rsyslog /etc/rsyslog.conf
    /etc/init.d/rsyslog restart
    iptables-restore $backup_iptables
fi
}

fun_config $1 && fun_iptables $1

: () {
cat   /var/log/iptables.log  | grep ID=5691
#Пиганули с ip 172.19.12.152 8.8.8.8 через маршурутизатор 172.19.12.13(iptables) у которого есть выход в интернет.
#icmp request
IPTAB: PREROUTING -t raw:IN=eth1.110 OUT= MAC=00:50:ba:85:53:43:00:1f:d0:84:e4:06:08:00:45:00:00:54 SRC=172.19.12.152 DST=8.8.8.8 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=7682 DF PROTO=ICMP TYPE=8 CODE=0 ID=5390 SEQ=1 
IPTAB: PREROUTING -t mangle:IN=eth1.110 OUT= MAC=00:50:ba:85:53:43:00:1f:d0:84:e4:06:08:00:45:00:00:54 SRC=172.19.12.152 DST=8.8.8.8 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=7682 DF PROTO=ICMP TYPE=8 CODE=0 ID=5390 SEQ=1 
IPTAB: PREROUTING -t nat:IN=eth1.110 OUT= MAC=00:50:ba:85:53:43:00:1f:d0:84:e4:06:08:00:45:00:00:54 SRC=172.19.12.152 DST=8.8.8.8 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=7682 DF PROTO=ICMP TYPE=8 CODE=0 ID=5390 SEQ=1 
IPTAB: FORWARD -t mangle:IN=eth1.110 OUT=eth1.69 MAC=00:50:ba:85:53:43:00:1f:d0:84:e4:06:08:00:45:00:00:54 SRC=172.19.12.152 DST=8.8.8.8 LEN=84 TOS=0x00 PREC=0x00 TTL=63 ID=7682 DF PROTO=ICMP TYPE=8 CODE=0 ID=5390 SEQ=1 
IPTAB: FORWARD -t filter:IN=eth1.110 OUT=eth1.69 MAC=00:50:ba:85:53:43:00:1f:d0:84:e4:06:08:00:45:00:00:54 SRC=172.19.12.152 DST=8.8.8.8 LEN=84 TOS=0x00 PREC=0x00 TTL=63 ID=7682 DF PROTO=ICMP TYPE=8 CODE=0 ID=5390 SEQ=1 
IPTAB: POSTROUTING -t mangle:IN= OUT=eth1.69 SRC=172.19.12.152 DST=8.8.8.8 LEN=84 TOS=0x00 PREC=0x00 TTL=63 ID=7682 DF PROTO=ICMP TYPE=8 CODE=0 ID=5390 SEQ=1 
IPTAB: POSTROUTING -t nat:IN= OUT=eth1.69 SRC=172.19.12.152 DST=8.8.8.8 LEN=84 TOS=0x00 PREC=0x00 TTL=63 ID=7682 DF PROTO=ICMP TYPE=8 CODE=0 ID=5390 SEQ=1 

#icmp replay,не во всех видим таблицах так как раньше выполняется conntrack, т.е. пакет идёт дальше по контракту.
IPTAB: PREROUTING -t raw:IN=eth1.69 OUT= MAC=00:50:ba:85:53:43:fc:8b:97:60:a7:14:08:00:45:00:00:54 SRC=8.8.8.8 DST=192.168.5.13 LEN=84 TOS=0x00 PREC=0x00 TTL=52 ID=29041 PROTO=ICMP TYPE=0 CODE=0 ID=5390 SEQ=1 
IPTAB: PREROUTING -t mangle:IN=eth1.69 OUT= MAC=00:50:ba:85:53:43:fc:8b:97:60:a7:14:08:00:45:00:00:54 SRC=8.8.8.8 DST=192.168.5.13 LEN=84 TOS=0x00 PREC=0x00 TTL=52 ID=29041 PROTO=ICMP TYPE=0 CODE=0 ID=5390 SEQ=1 
#!!!CONNTRACK
IPTAB: FORWARD -t mangle:IN=eth1.69 OUT=eth1.110 MAC=00:50:ba:85:53:43:fc:8b:97:60:a7:14:08:00:45:00:00:54 SRC=8.8.8.8 DST=172.19.12.152 LEN=84 TOS=0x00 PREC=0x00 TTL=51 ID=29041 PROTO=ICMP TYPE=0 CODE=0 ID=5390 SEQ=1 
IPTAB: FORWARD -t filter:IN=eth1.69 OUT=eth1.110 MAC=00:50:ba:85:53:43:fc:8b:97:60:a7:14:08:00:45:00:00:54 SRC=8.8.8.8 DST=172.19.12.152 LEN=84 TOS=0x00 PREC=0x00 TTL=51 ID=29041 PROTO=ICMP TYPE=0 CODE=0 ID=5390 SEQ=1 
IPTAB: POSTROUTING -t mangle:IN= OUT=eth1.110 SRC=8.8.8.8 DST=172.19.12.152 LEN=84 TOS=0x00 PREC=0x00 TTL=51 ID=29041 PROTO=ICMP TYPE=0 CODE=0 ID=5390 SEQ=1
#!!!CONNTRACK
}
