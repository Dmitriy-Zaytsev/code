#!/bin/bash

COMMAND="
DROP INDEX history_1 CASCADE;
DROP TABLE history CASCADE;
DROP INDEX history_log_1 CASCADE;
DROP TABLE history_log CASCADE;
DROP INDEX history_str_1 CASCADE;
DROP TABLE history_str CASCADE;
DROP INDEX history_text_1 CASCADE;
DROP TABLE history_text CASCADE;
DROP INDEX history_uint_1 CASCADE;
DROP TABLE history_uint CASCADE;
DROP INDEX trends_1 CASCADE;
DROP INDEX trends_uint_1 CASCADE;
DROP TABLE trends CASCADE;
DROP TABLE trends_uint CASCADE;
DROP TABLE events CASCADE;
DELETE FROM events;
DELETE FROM problem;
UPDATE triggers SET value='0' WHERE value='1';
"

#systemctl stop zabbix-server.service
#systemctl stop apache2.service
#systemctl start postgresql.service


echo "$COMMAND" | sudo -u zabbix psql -U zabbix zabbix -h /var/run/postgresql -p 5432
sudo -u zabbix psql -U zabbix zabbix -h /var/run/postgresql -p 5432 -c "SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE (TABLE_NAME LIKE '%history%' OR TABLE_NAME LIKE '%trends%') AND TABLE_NAME NOT LIKE '%proxy%';" | grep -E "(history|trends)" | xargs -i sudo -u zabbix psql -U zabbix zabbix -h /var/run/postgresql -p 5432 -c "DROP TABLE {} CASCADE;"
sudo -u zabbix psql -U zabbix zabbix -h /var/run/postgresql -p 5432 -c "SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE (TABLE_NAME LIKE '%history%' OR TABLE_NAME LIKE '%trends%') AND TABLE_NAME NOT LIKE '%proxy%';" | grep -E "(history|trends)" | xargs -i sudo -u zabbix psql -U zabbix zabbix -h /var/run/postgresql -p 5432 -c "DROP INDEX {} CASCADE;"

sudo -u zabbix psql -U zabbix zabbix -h /var/run/postgresql -p 5432 -f /usr/share/doc/zabbix-server-pgsql/create.sql
#echo "CREATE INDEX trends_uint_1 ON trends_uint (itemid,clock);" |  sudo -u zabbix psql -U zabbix zabbix -h /var/run/postgresql -p 5432
#echo "CREATE INDEX trends_1 ON trends (itemid,clock);" |  sudo -u zabbix psql -U zabbix zabbix -h /var/run/postgresql -p 5432

sudo -u zabbix psql zabbix -U zabbix -h /var/run/postgresql -p 5432 -c "REINDEX DATABASE zabbix;"
sudo -u zabbix psql zabbix -U zabbix -h /var/run/postgresql -p 5432 -c "VACUUM FULL;"

sudo -u postgres psql postgres -U postgres -h /var/run/postgresql -p 5432 -c "REINDEX DATABASE postgres;"
sudo -u postgres psql postgres -U postgres -h /var/run/postgresql -p 5432 -c "VACUUM FULL;"

#systemctl stop postgresql.service
#killall postgresql
#systemctl start postgresql.service
#systemctl start zabbix-server.service
#systemctl start apache2.service
