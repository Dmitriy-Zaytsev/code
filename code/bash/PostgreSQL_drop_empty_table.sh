#!/bin/bash

file=/tmp/empty_table.txt
file_log=/tmp/empty_table.log

COMMAND="SELECT relname FROM pg_stat_all_tables WHERE n_live_tup=0 AND (relname LIKE 'history%' OR relname LIKE 'trends%') AND relname LIKE '%partition%';"
echo "$COMMAND" | sudo -u postgres psql -U postgres zabbix -h /var/run/postgresql -p 5432 --tuples-only > $file

for string in `(cat $file)`
 do
   echo $string
   echo "DROP TABLE "$string" CASCADE;" | sudo -u postgres psql -U postgres zabbix -h /var/run/postgresql -p 5432 &>$file_log
echo --
 done
