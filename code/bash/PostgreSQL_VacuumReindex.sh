#/bin/bash
sudo -u zabbix psql zabbix -U zabbix -h /var/run/postgresql -p 5432 -c "VACUUM ANALYZE VERBOSE;"
sudo -u zabbix psql zabbix -U zabbix -h /var/run/postgresql -p 5432 -c "REINDEX DATABASE zabbix;"
