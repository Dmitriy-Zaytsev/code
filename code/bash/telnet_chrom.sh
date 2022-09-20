#!/bin/bash
#echo $@ > /tmp/1 #Проверить что отдаёт браузер(unetlab) как параметр для xdg(xdg-open).
xterm -e "telnet `(echo $@ | sed 's/.*:\/\///g' | sed 's/:/ /g')`"
