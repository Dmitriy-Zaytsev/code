#!/bin/bash
#echo $@ > /tmp/1
ip=`(echo $@ | sed 's/.*\/\/\(.*\):\(.*\)/\1/g')`
port=`(echo $@ | sed 's/.*\/\/\(.*\):\(.*\)/\2/g')`
vncviewer $ip:$port
