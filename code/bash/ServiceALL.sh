#!/bin/bash -x

fun () {
systemctl $1 postgresql.service
[ "$1" = "stop" ] &&  killall postgresql
systemctl $1 pgbouncer.service
systemctl $1 zabbix-server.service
systemctl $1 zabbix-agent.service
systemctl $1 snmptrapd.service
systemctl $1 apache2.service
systemctl $1 grafana-server.service
}

case $1 in
 restart ) fun stop; fun start;;
 start ) fun start;;
 stop ) fun stop;;
esac
