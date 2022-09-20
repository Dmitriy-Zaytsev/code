#!/bin/bash
exit 5 #от случайного запуска.
ip='172.19.12.'
communityR='ghbitktw'
communityRW='test123456'
min_proc="3"

fun_send_mail () {
/usr/bash_scr/mail_send_mts.sh "$1" &>/dev/null
echo "$1"
}

for oct in `(seq 1 254)`
 do
  ip_addr="$ip$oct"
  ping $ip_addr -c 1 -w 1 &>/dev/null || continue
  [ ! "\"Delta\"" = "`(snmpget -c $communityR -v 1 $ip_addr  enterprises.2254.2.4.1.1.0 -t 1 -Onqv 2>/dev/null)`" ] && continue
  sysname=`(snmpget -c $communityR -v 1 $ip_addr  SNMPv2-MIB::sysName -Oqv 2>/dev/null)`
  sysloc=`(snmpget -c $communityR -v 1 $ip_addr  SNMPv2-MIB::sysLocation -Oqv 2>/dev/null)`
  echo $ip_addr $sysname $sysloc
  voltage=`(snmpget -v 1 -c $communityRW $ip_addr UPS-MIB::upsInputVoltage.1 -Oqv 2>/dev/null | sed -E 's/([0-9]*).*/\1/g')`
  [ "$voltage" -le "20" ] && { fun_send_mail "UPS-$sysname_$sysloc нет питания от сети." && continue;}
  proc=`(snmpget -c $communityRW -v 1 $ip_addr .1.3.6.1.2.1.33.1.2.4.0 -Oqv  2>/dev/null | sed -E 's/([0-9]*).*/\1/g')`
  [ "$proc" -le "$min_proc" ] && continue
  snmpset -v 1 -c $communityRW $ip_addr UPS-MIB::upsTestId o upsTestDeepBatteryCalibration &>/dev/null
  sleep 4
  status=`(snmpget -v 1 -c $communityRW $ip_addr UPS-MIB::upsOutputSource.0 -Onqv 2>/dev/null)`
  time=`(snmpget -v 1 -c $communityRW $ip_addr .1.3.6.1.2.1.33.1.2.3.0 -Onqv 2>/dev/null | sed -E 's/([0-9]*).*/\1/g')`
  [ "$status" = "battery" ] && fun_send_mail "Переведён UPS-$sysname_$sysloc в режим от батареи, до разряда осталось $time мин." || { echo "НЕпереведён UPS-$sysname_$sysloc в режим от батареи." && continue;}

   while true
    do
     proc=`(snmpget -c $communityRW -v 1 $ip_addr .1.3.6.1.2.1.33.1.2.4.0 -Oqv  2>/dev/null | sed -E 's/([0-9]*).*/\1/g')`
     status=`(snmpget -v 1 -c $communityRW $ip_addr UPS-MIB::upsOutputSource.0 -Onqv 2>/dev/null)`
     [ "$status" = "battery" ] || break
     echo -en "\r$ip_addr $sysname_$sysloc -- $proc%  "
       if [ "$proc" -le "$min_proc" ]
        then
         snmpset -v 1 -c $communityRW $ip_addr UPS-MIB::upsTestId o upsTestAbortTestInProgress &>/dev/null
         sleep 4
         status=`(snmpget -v 1 -c $communityRW $ip_addr UPS-MIB::upsOutputSource.0 -Onqv 2>/dev/null)`
         [ ! "$status" = "battery" ] && break
       fi
       sleep 1
   done
   echo -e "\n"
   time=`(snmpget -v 1 -c $communityRW $ip_addr .1.3.6.1.2.1.33.1.2.3.0 -Onqv 2>/dev/null | sed -E 's/([0-9]*).*/\1/g')`
   fun_send_mail "Переведён UPS-$sysname_$sysloc в режим от сети, до разряда осталось $time мин. $proc%."
   echo quit
done
