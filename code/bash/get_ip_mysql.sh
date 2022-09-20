#!/bin/bash

location=xxxxxxxx
mgs=xxxxxxxxx
ip=xxxxxxxxx
inf=xxxxxxxxx
while getopts "i:m:l:u:" Opts
  do
     case $Opts in
	i) ip=$OPTARG;;
        l) location=$OPTARG;;
        m) mgs=$OPTARG;;
	u) inf=$OPTARG;;
     esac
  done


user=dima
ipdb=192.168.33.2
portdb=22
ipmy=192.168.33.13
portmy=44
db=ipplan
userdb=ipplan
passworddb=ipplan

echo  "SELECT  userinf,location,descrip,inet_ntoa(ipaddr)  FROM ipaddr WHERE (location LIKE '%location%' OR descrip LIKE '%$mgs%' OR inet_ntoa(ipaddr) LIKE '$ip' OR userinf LIKE '%$inf%');"\
 | ssh $user@$ipdb -p $portdb "mysql --skip-column-names --host=localhost --user=$userdb --password=$passworddb $db" |  tr '\t' '|'  | sed 's/ /_/g' | tr '|' '\t'
