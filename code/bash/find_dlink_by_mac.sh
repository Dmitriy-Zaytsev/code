#!/bin/bash
#Скрипт для подсчёта в 10 влане dlink-ов.
file=/tmp/mgs12j-56ks.csv
file_new=/tmp/mgs12-56ks_new.csv
> $file_new
#172.19.2.118;5;1
#172.19.2.119;3;2
tmpfile=/tmp/find_dgs.tmp
tmpfile2=/tmp/find_dgs2.tmp

vendor=/var/lib/vendor_mac_wireshark.txt
username=dima.z
password=pfqwtd

community=ghbitktw

fun_exp_dlink () {
/usr/bin/expect -c \
"
set timeout 1
send_user \n\n$ip\n
sleep 1
spawn /usr/bin/telnet $ip
set var_expect 1
send_user \$var_expect
while 1 {
expect Username  {send "$username"\n }
expect Password {send "$password"\n }
expect # {break}
}
send \n\n\n
while 1 {expect # { send show\ fdb\ port\ "$port"\n ; break}}
sleep 1
send \n
while 1 {expect # { send logout\n ; break}}
expect sdfsdfsfd
" | tee $tmpfile
sed -n '/^10 .*/p' $tmpfile -i
return 0
}


fun_exp_edgecore () {
/usr/bin/expect -c \
"
set timeout 1
send_user \n\n$ip\n
sleep 1
spawn /usr/bin/telnet $ip
set var_expect 1
send_user \$var_expect
while 1 {
expect Username  {send "$username"\n }
expect Password {send "$password"\n }
expect # {break}
}
send \n\n\n
while 1 {expect # { send show\ mac-address-table\ interface\ ethernet\ 1/"$port"\n ; break}}
while 1 {expect # { send exit\n ; break}}
expect sdfsdfsfd
" | tee $tmpfile
sed -n '/10 Learn/p' $tmpfile -i
return 0
}

while read string
 do
  echo  $string
  ip=`(echo $string | cut -f 1 -d ";")`
  port=`(echo $string | cut -f 2 -d ";")`
  abon=`(echo $string | cut -f 3 -d ";")`
  model=`(snmpget -c $community -v 2c $ip sysDescr.0 -Oqnv 2>/dev/null| sed 's/ //g')`
  #echo $model
  if [ "$model" = "DES-1210-28/ME6.07.B039" ]
    then
    fun_exp_dlink
  fi
  if [ "$model" = "ECS3510-28T" ]
    then
    fun_exp_edgecore
  fi
  cat $tmpfile | tr '[:lower:]' '[:upper:]' | sed -E  "s/.*(([A-F,0-9][A-F,0-9][-:]){5}([A-F,0-9][A-F,0-9])).*/\1/g" | sed 's/-\|:/-/g' | sed -n "/^[A-F,0-9]\{2\}-.*/p" > $tmpfile2
  amount_dlink=`(grep -i d-link $vendor |  sed -E  "s/.*(([A-F,0-9][A-F,0-9][-:]){2}([A-F,0-9][A-F,0-9])).*/\1/g" | tr ":" "-" | xargs -i grep "{}" $tmpfile2 2>/dev/null | wc -l)`
  echo "$ip;$port;$abon;$amount_dlink" >> $file_new
 done < $file
