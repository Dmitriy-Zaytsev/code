#!/bin/bash
export ip=192.168.0.45
export port="3389"
export user="operator1"
export password="ratepor1"

rdesktop $ip:$port -u $user -p $password -g 1920x1000

