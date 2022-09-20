#!/bin/bash
export ip=83.151.14.181
export port="31005"
export user="operator2"
export password="ratepor2"

rdesktop $ip:$port -u $user -p $password -g 1920x1000 -r sound:remote

