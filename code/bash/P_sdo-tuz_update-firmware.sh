#!/bin/bash
file_ip=$1
community_ro="ghbitktw"
#community_rw="ghbitktw"
log_file=/tmp/`(basename $0)`_$$.log
snmp_version="1" #1|2c
tftp_server="192.168.33.6"

packages_inst='
dos2unix
'

fun_check_package () {
for package in $packages_inst
do
 ! dpkg-query -s "$package" &>/dev/null &&  { echo "No install $package."; exit 2;}
done
}

[ ! -f "$file_ip" ] &&  { echo "$file_ip is not a file."; exit 2;}
[ ! -r "$file_ip" ] &&  { echo "$file_ip file no read."; exit 2;}
dos2unix $file_ip

greenB='\e[1;32m'
green='\e[0;32m'
redB='\e[1;31m'
rescol='\e[0m'
echo -e "\n"$greenB"Log file - $log_file"$rescol"\n"

fun_log () {
level="$1"
message="$2"
#progname=`(basename $0)`
date=`(date "+%d/%m/%y_%H:%M:%S")`
echo "$date $progname[$level]: $message" | tee -a $log_file
}


while read ip
do
  unset model
  echo -en "\n"$green"IP: $ip"$rescol"\n"
  ping -c 1 $ip -W 1 &>/dev/null || { fun_log WARNING "Not reachable $ip";continue;}
  model=`(snmpget -c $community_ro -v $snmp_version $ip .1.3.6.1.2.1.1.1.0 -Oqv 2>/dev/null)`
  [ -z "$model" ] && { fun_log WARNING "No answer on snmp $ip";continue;}
  case $model in
    sdo3002 ) :;; #tftp file sdo3002_update_v12_9_1.bsk
    sdo3001 ) :;; #tftp file sdo3002_update_v12_9_2.bsk
    tuz19-2003 ) :;; #tftp file tuz19_update_v12_10_1.bsk
    * ) fun_log WARNING "No action for model $model $ip";continue;;
  esac
  enterprises_tree=`(snmpget -c $community_ro -v $snmp_version $ip .1.3.6.1.2.1.1.2.0 -Onqv 2>/dev/null)`
  community_rw=`(snmpget -c $community_ro -v $snmp_version $ip "$enterprises_tree".4.2.3.0 -Onqv 2>/dev/null | sed 's/"//g')`
  firmware_version_current=`(snmpwalk -c $community_ro -v $snmp_version $ip  "$enterprises_tree".1.3.0 -Oaqv | sed 's/"//g')`
  #echo -e "MODEL: $model\nENTERPRISES_TREE: $enterprises_tree\nCOMMUNITY_RW: $community_rw\nFIRMWARE_VERSION_CURRENT: $firmware_version_current"
  snmpset -c $community_rw -v $snmp_version $ip "$enterprises_tree".4.6.1.0 s "$tftp_server" &>/dev/null
  snmpset -c $community_rw -v $snmp_version $ip "$enterprises_tree".4.6.2.0 i 129 &>/dev/null
  unset firmware_version_new
  sleep 10
  s=0
  while [ "$s" -le 30 ] #240 sec
  do
     firmware_version_new=`(snmpwalk -c $community_ro -v $snmp_version $ip  "$enterprises_tree".1.3.0 -Oaqv 2>/dev/null | sed 's/"//g')`
     [ -n "$firmware_version_new" ] && break
     sleep 8
     ((s=s+1))
  done
  [ -z "$firmware_version_new" ] && { fun_log WARNING "No answer on snmp,after firmware $ip";continue;}
  if [ ! "$firmware_version_new" = "$firmware_version_current" ]
  then
     fun_log INFO "Successfully $ip firm: $firmware_version_current --> $firmware_version_new"
  else
     fun_log WARNING "No ready $ip firm: $firmware_version_current --> $firmware_version_new"
  fi
done < "$file_ip"
