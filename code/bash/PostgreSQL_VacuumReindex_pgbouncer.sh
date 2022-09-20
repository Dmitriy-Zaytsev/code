#/bin/bash
#(sudo -u zabbix psql -h /var/run/postgresql -p 5432 pgbouncer -c "PAUSE zabbix;") &
sudo -u zabbix psql -h /var/run/postgresql -p 5432 pgbouncer -c "PAUSE zabbix;"
sudo -u zabbix psql zabbix -U zabbix -h /var/run/postgresql -p 6432 -c "REINDEX DATABASE zabbix;"
sudo -u zabbix psql zabbix -U zabbix -h /var/run/postgresql -p 6432 -c "VACUUM ANALYZE VERBOSE;"
#kill $!
sudo -u zabbix psql -h /var/run/postgresql -p 5432 pgbouncer -c "RESUME zabbix;"
