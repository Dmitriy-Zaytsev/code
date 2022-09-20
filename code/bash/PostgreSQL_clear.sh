#!/bin/bash
DATE=`(date -d '(date +%d/%m/%y 00:00:00)' +"%s")`
#sudo -u zabbix psql  zabbix -U zabbix -c  "SELECT relname || '.' || relname AS "relation",\
#    pg_size_pretty(pg_relation_size(C.oid)) AS "size"\
#  FROM pg_class C\
#  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)\
#  WHERE nspname NOT IN ('pg_catalog', 'information_schema')\
#  ORDER BY pg_relation_size(C.oid) DESC\
#  LIMIT 3;"

#Выведим только 10и саммых больших таблицы.
TABLE=`(sudo -u zabbix psql  zabbix -U zabbix --tuples-only -c  "SELECT  relname AS "name"\
  FROM pg_class C\
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)\
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')\
  ORDER BY pg_relation_size(C.oid) DESC\
  LIMIT 10;")`

/etc/init.d/postgresql start
sleep 2
/etc/init.d/zabbix-server stop
/etc/init.d/apache2 stop

for table in $TABLE
 do
  echo "Очистка данных старше `(date "+%d/%m/%y 00:00:00")` в таблице $table."
  sudo -u zabbix psql  zabbix -U zabbix -c "DELETE FROM $table WHERE clock < '$DATE';"
 done
sudo -u postgres psql postgres -U postgres -c "VACUUM FULL;"
sudo -u zabbix psql zabbix -U zabbix -c "VACUUM FULL;"
sudo -u zabbix psql zabbix -U zabbix -c "VACUUM ANALYZE VERBOSE;"
sudo -u zabbix psql zabbix -U zabbix -c "REINDEX DATABASE zabbix;"
sudo -u postgres psql postgres -U postgres -c "REINDEX DATABASE postgres;"
/etc/init.d/zabbix-server start
/etc/init.d/apache2 start
