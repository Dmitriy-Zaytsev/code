#!/bin/bash
command="df -h
ls -la
pwd
"

while read com
 do
  $com || exit 1
 done < <(echo "$command")


while read com
 do
  $com || exit 1
 done <<LIST
echo 172.19.3.110
true
echo 172.19.1.225
false
echo "Success"
LIST
