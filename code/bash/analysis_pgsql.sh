#!/bin/bash -x
nano /etc/postgresql/9.4/main/postgresql.conf
sudo -u postgres pg_ctl reload -s -D /var/lib/postgresql/9.4/main
echo " "
> /var/log/postgresql/postgresql-9.4-main.log
sleep 600
pgbadger -J 8 --format syslog  --timezone +03  -a 10 -A 10 /var/log/postgresql/postgresql-9.4-main.log -o /tmp/postgresql_pgbadger.html
scp -P 44 /tmp/postgresql_pgbadger.html dima@192.168.33.13:/tmp/
