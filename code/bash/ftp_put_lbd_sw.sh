#!/bin/bash
logfile=/var/log/switch/all.log
tmpfile=/tmp/all.log
ip=192.168.33.14
grep -i "lbd " "$logfile"  > "$tmpfile"
lftp -u anonymous,anonymous -e "put $tmpfile;quit" "$ip"
rm $tmpfile
