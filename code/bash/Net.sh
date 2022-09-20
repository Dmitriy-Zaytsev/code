#!/bin/bash
#[ "$UID" != "0" ] && echo "Нет прав для исполнения nmap." && exit 3

#Переменные.
log_dir="/tmp/"
date_time=`( date "+%d-%m-%y_[%H:%M]")`
file_scan=$log_dir$date_time.scan
file_log=$log_dir$date_time.log
ACTION=;
community_mas="ghbitktw ghb31b08yb"
community_mas=($community_mas) #Массив  ${community[$i]}
psql_base='database_network'
psql_table='table_scan'
tmpfile=`(mktemp)`


#Проверка установленных пакетов.
packages='
ipcalc
snmp
nmap
expect
snmp-mibs-downloader
'
for pack in $packages
 do
  dpkg-query -s $pack &>/dev/null || { echo "Не установлен пакет $pack" && exit 3;}
 done







#PostgreSQL
psql_fun () {
p_ip=${ip:-0.0.0.0}
p_hostname=${hostname:-hostname}
p_model=${model:-model}
p_firmw=${firmw:-firmware}
p_basemac=${basemac:-00:00:00:00:00:00}
p_icmp=${icmp:-0}
p_snmp=${snmp:-0}
p_telnet=${telnet:-0}
p_ssh=${ssh:-0}
tput el
echo -en "Вывод результата в базу PostgreSQL, для вывода в STDOUT "$0" -n 172.19.0.1/32"
#echo ..
#echo $p_hostname
#echo $p_model
#echo $p_firmw
#echo $p_basemac
#echo ..
psql $psql_base -U user_net -c "INSERT INTO $psql_table(date,time,ip,hostname,model,firmware,mac,icmp,snmp,telnet,ssh) VALUES (CURRENT_DATE,CURRENT_TIME,"\'$p_ip\'","\'$p_hostname\'","\'$p_model\'","\'$p_firmw\'","\'$p_basemac\'","\'$p_icmp\'","\'$p_snmp\'","\'$p_telnet\'","\'$p_ssh\'");" &>/dev/null
}



####SNMP_START
dgs1100-08_mibs () {
ip=$1
/usr/bin/expect -c "\
spawn telnet $ip
send admin\n
send rabbit\n
send show\ switch\n
expect sdfsdf
logout" 2>/dev/null > $tmpfile
model=DGS_1100-08
basemac=`(cat  $tmpfile  | grep MAC --binary-files=text | sed 's/MAC.*\: \(.*\)/\1/g' | tr -d $'\x0d')`
firmw=`(cat  $tmpfile  | grep Firmware --binary-files=text | sed 's/Firmware.*\: Build \(.*\)/\1/g' | tr -d $'\x0d')`
loader=`(cat  $tmpfile  | grep "Boot PROM" --binary-files=text | sed 's/Boot.*\: Build \(.*\)/\1/g' | tr -d $'\x0d')`
hostname=`(cat  $tmpfile  |  grep "admin#.s.h.o.w. .s.w.i.t.c.h." --binary-files=text | sed 's/^\(.*\):.*/\1/g' | tr -d $'\x0d')`
rm $tmpfile
}


cisco_mibs () {
mib_firmw='enterprises.9.2.1.73.0'
mib_basemac='enterprises.9.9.98.1.1.1.1.2.1'
mib_hostname='sysName.0'
mib_model='entPhysicalModelName.1'
model=`(snmpget -r 1 -t 2 -c $community -v 2c $ip $mib_model -Oqv 2>/dev/null | sed -E 's/(\/| |")//g' | sed 's/.*\$\(.*\)\$.*/\1/g')`
detect_sw=1
}

des1210_mibs () {
mib_firmw='.1.3.6.1.2.1.16.19.2.0'
mib_basemac='.1.3.6.1.2.1.17.1.1.0'
mib_hostname='.1.3.6.1.2.1.1.5.0'
mib_model='enterprises.171.10.75.15.2.2.6.0'
sw_mibs_add
detect_sw=1
}

ec3510ma_mibs () {
mib_firmw='.1.3.6.1.2.1.47.1.1.1.1.9.201'
mib_basemac='.1.3.6.1.2.1.2.2.1.6.1001'
mib_hostname='.1.3.6.1.2.1.1.5.0'
mib_loader='enterprises.259.8.1.11.1.1.3.1.4.1'
mib_diag='enterprises.259.8.1.11.1.1.3.1.5.1'
sw_mibs_add
detect_sw=1
}

es3528M_mibs () {
mib_firmw='enterprises.259.6.10.94.1.1.3.1.6.1'
mib_basemac='.1.3.6.1.2.1.2.2.1.6.1001'
mib_hostname='.1.3.6.1.2.1.1.5.0'
mib_loader='enterprises.259.6.10.94.1.1.3.1.4.1'
mib_diag='enterprises.259.6.10.94.1.1.3.1.5.1'
mib_model='enterprises.259.6.10.94.1.1.5.1.0'
sw_mibs_add
detect_sw=1
}

ecs3510-28T_mibs () {
mib_firmw='enterprises.259.10.1.27.1.1.3.1.6.1'
mib_basemac='.1.3.6.1.2.1.2.2.1.6.1001'
mib_hostname='.1.3.6.1.2.1.1.5.0'
mib_loader='enterprises.259.10.1.27.1.1.3.1.4.1'
mib_diag='enterprises.259.10.1.27.1.1.3.1.5.1'
mib_model=''
sw_mibs_add
detect_sw=1
}

sw_mibs_add () {
[ -n "$mib_loader" ] && loader=`(snmpget -r 1 -t 2 -c $community -v 2c $ip $mib_loader  -Oqv 2>/dev/null | sed -E 's/(\/| |")//g')`
[ -n "$mib_diag" ] && diag=`(snmpget -r 1 -t 2 -c $community -v 2c $ip $mib_diag  -Oqv 2>/dev/null | sed -E 's/(\/| |")//g')`
[ -n "$mib_model" ] && model=`(snmpget -r 1 -t 2 -c $community -v 2c $ip $mib_model -Oqv 2>/dev/null | sed -E 's/(\/| |")//g')`
}

des2108_mibs () {
mib_basemac='ifPhysAddress.604'
mib_hostname='sysName.0'
mib_firmw='enterprises.171.10.61.3.11.1.0'
model=`(echo $model | sed 's/\(.*2108\).*/\1/g')`
detect_sw=1
}

snmp_walk () {
[ "$snmp" = "0" ] && return 1
detect_sw=0;
unset mib_firmw mib_basemac mib_hostname mib_diag mib_loader mib_model \
model firmw basemac loader diag
i='0'
while [[ -z "$model"  &&  ! "$i" = ${#community_mas[@]} ]]
do
 community="${community_mas[$i]}"
 model=`(snmpget -r 1 -t 2 -c ${community_mas[$i]} -v 2c $ip .1.3.6.1.2.1.1.1.0  -Oqv 2>/dev/null | sed -E 's/(\/| |")//g')`
 ((i=$i+1))
done
case $model in
  *DES-1210-28ME*) des1210_mibs;;
   ES3510MA) ec3510ma_mibs;;
  *Edge-CoreFEL2SwitchES3528M*|*Edge-CoreFEL2SwitchES3552M*) es3528M_mibs;;
   ECS3510-28T|ECS3510-52T) ecs3510-28T_mibs;;
  *DES-2108*) des2108_mibs;;
  *[C,c][I,i][S,s][C,c][O,o]*) cisco_mibs;;
  *Realtek-Switch*) dgs1100-08_mibs $ip;;
  *DES-3200-10C1FastEthernetSwitch*) :;;
esac
#echo -e "-----\nTESTmib: firmw-$mib_firmw basemac-$mib_basemac hostname-$mib_hostname\n-----" 1>&2
if [ "$detect_sw" = "1" ]
 then
   [ ! -n "$firmw" ] && firmw=`(snmpget -r 1 -t 2 -c $community -v 2c $ip $mib_firmw  -Oqv 2>/dev/null | sed -E 's/(\/| |")//g')`
   [ ! -n "$basemac" ] && basemac=`(snmpget -r 1 -t 2 -c $community -v 2c $ip $mib_basemac -Oqv 2>/dev/null | sed -E 's/(\/| |")//g')`
   [ ! -n "$hostname" ] && hostname=`(snmpget -r 1 -t 2 -c $community -v 2c $ip $mib_hostname  -Oqv 2>/dev/null | sed -E 's/(\/| |")//g')`
fi

#Если есть в переменной No Such (т.е. нет такого oid, например для Dlink1210), тогда заменить на model/firmware..., и уберём возможные #,пробел и ".
model=`(echo $model | sed 's/.*No.*Such.*/model/g' | sed 's/ \|"\|#//g')`
firmw=`(echo $firmw | sed 's/.*No.*Such.*/firmware/g' | sed 's/ \|"\|#//g')`
basemac=`(echo $basemac | sed 's/.*No.*Such.*/00:00:00:00:00:00/g' | sed 's/ \|"\|#//g')`
hostname=`(echo $hostname | sed 's/.*No.*Such.*/hostname/g' | sed 's/ \|"\|#//g')`
loader=`(echo $loader | sed 's/.*No.*Such.*/loader_not_specified/g' | sed 's/ \|"\|#//g')`
diag=`(echo $diag | sed 's/.*No.*Such.*/diag_not_specified/g' | sed 's/ \|"\|#//g')`
#
[ -z "$model" ] && { echo "$ip --> Не удалось получить модель коммутатора."  && return 1;}
firmw=$firmw${loader:+__$loader}${diag:+__$diag}
#all_data="$ip#$hostname#$model#$firmw#$basemac"
#echo $all_data
return 0
}
####SNMP_END




#Проверка на icmp и snmp....
test_ip () {
icmp=0
snmp=0
telnet=0
ssh=0
ping $ip -l 5 -c 2 -W 1 -D -n &>/dev/null && icmp=1 || echo "$ip --> Недоступен."
nmap -sU -n -p 161 $ip | grep -i '161.*open' &>/dev/null && snmp=1 || echo "$ip --> Не открыт порт. 161(SNMP)"
[ ! "$snmp" = "1" -a ! "$icmp" = 1 ] && return 1

nmap -n -p 23 $ip -Pn | grep -i '23.*open' &>/dev/null && telnet=1
nmap -n -Pn -p 22 $ip | grep -i '22.*open' &>/dev/null && ssh=1
return 0
}

#2-е функции в одной, проверка и snmp опрос.
test_ip_and_snmp_walk () {
test_ip && snmp_walk || return 1
return 0
}

#В зависимости от того что мы хотим делать, сканировать или пробежаться скриптом.
act () {
unset model firmw basemac hostname loader diag
if [ "$ACTION" = "scan" ]
  then
    #[ ! -e "$file_scan" ] && echo "ip # hostname # model # firmw # mac" | tee  "$file_scan"
    #test_ip_and_snmp_walk >> "$file_scan"
    #tail -n 1 "$file_scan"
    :
    test_ip_and_snmp_walk
    psql_fun
  elif [ "$ACTION" = "config" ]
      then :
        #(test_ip && { snmp_walk && configure;}) | tee -a "$file_log"
      elif [ -z "$ACTION" ]
          then
           test_ip_and_snmp_walk
           echo -e "------ip: $ip\nhostname: $hostname\nmodel: $model firmware: $firmw basemac: $basemac\nicmp: $icmp snmp: $snmp telnet: $telnet ssh: $ssh\n------\n\n"
fi
}

#Получение ip из файла.
ip_file () {
file_ip=$1
[ ! -f $file_ip ] && { echo "Не являеться файлом $file_ip." && return 1;}
[ ! -r $file_ip ] && { echo "Нет прав на чтение $file_ip." && return 1;}
while read ip
 do
  ipcalc $ip | grep -i invalid &>/dev/null &&  { echo "Не некорректный IP адрес $ip." && continue;}
  act
 done < $file_ip
}


#Получение ip из указаной подсети.
ip_net () {
net=$1
ipcalc $net | grep -i invalid &>/dev/null && { echo "Не некорректный IP адрес $net." && exit 1;}
host_min=`(ipcalc -n -b $net | grep -i hostmin | sed -E "s/ {1,99}/ /g" | cut -d  " "  -f 2)`
host_max=`(ipcalc -n -b $net | grep -i hostmax | sed -E "s/ {1,99}/ /g" | cut -d  " "  -f 2)`
[ "$host_min" == "" -a "$host_max" == "" ] && \
{ host_min=`(ipcalc -n -b $net | grep -i address | sed -E "s/ {1,99}/ /g" | cut -d  " "  -f 2)` &&\
 host_max=$host_min;}
oct_min=`(echo $host_min | tr '.' '\n')`
oct_min=($oct_min)
oct_max=`(echo $host_max | tr '.' '\n')`
oct_max=($oct_max)
for oct1 in `seq ${oct_min[0]} ${oct_max[0]}`
 do
  for oct2 in `seq ${oct_min[1]} ${oct_max[1]}`
   do
    for oct3 in `seq ${oct_min[2]} ${oct_max[2]}`
     do
      for oct4 in `seq ${oct_min[3]} ${oct_max[3]}`
       do
         ip="$oct1.$oct2.$oct3.$oct4"
         #Жёлт.
         tput setaf 3
         #Вывод не спускаясь на следующию строку удаляя предидущее.
         tput el
         echo -en $ip
         #Белый.
         tput setaf 7
         #Встаём курсором на позицию ноль.
         tput hpa 0
         #export ip
         act
       done
     done
   done
 done
}


help () {
echo "СПРАВКА"
}

#Проверка лог/скан файла указаного ключём.
dir_log () {
log_dir=$1
[ -z "$log_dir" ] && { echo "Не указан аргумент для ключа '-l'." && return 1;}
[ ! -e "$log_dir" ] && { echo "Не существут $log_dir." && return 1;}
[ ! -r "$log_dir" ] && { echo "Нет прав на чтение $log_dir." && return 1;}
[ ! -d "$log_dir" ] && { echo "Не являеться директорией $log_dir." && return 1;}
file_scan=$log_dir$date_time.scan
file_log=$log_dir$date_time.log
}

#Проверка для ключей без параметров, например -S, для того что бы он не
#не взял следующий ключь как аргумент для первого.
check_arg_getopts () {
[[ "$OPTARG" =~ - ]] && unset OPTARG && ((OPTIND=OPTIND-1))
#export OPTARG
#export OPTIND
}

#Разбор ключей.
while getopts ":n:f:l:hSC" Opt
do
check_arg_getopts
 case $Opt in
  n) FUN="ip_net $OPTARG" || exit 1;;
  f) FUN="ip_file $OPTARG" || exit 1;;
  l) dir_log $OPTARG || exit 1;;
  S) ACTION=scan;;
  C) ACTION=config;;
  h) help && exit 0;;
  *) ;;
 esac
done

#Запуск справки если после getopts $FUN пустая.
[ -z "$FUN" ] && $0 -h && exit 1

echo -e "\n\n------------------------------------"
echo -e "$0 $@\n"
[ "$ACTION" = "config" ] && echo "Log файл о выполнении скриптов $file_log."
[ "$ACTION" = "scan" ] && echo "Результат сканирования в базе $psql_base в таблице $psql_table."
[ -z "$ACTION" ] && echo "Результат сканирования выведиться на STDOUT."
echo -e "------------------------------------\n\n"
#read -t 2 -s -n 1 -p "Продолжить?(Y/n)" key && [ "$key" = "n" ] && exit 1


#Запуск после разбора ключей.
$FUN
psql $psql_base -U user_net -c "DELETE FROM table_scan WHERE date<(date (CURRENT_DATE) - interval '1 month');"
echo "Время исполнения $0 $@ $(($SECONDS/60)) минут."

