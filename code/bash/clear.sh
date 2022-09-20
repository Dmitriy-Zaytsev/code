#!/bin/bash
OLDIFS="$IFS"
IFS=$'\n'
for string in `(lsof | grep \(deleted\))`
 do
  pid=`(echo "$string" | sed -E "s/ {1,}/ /g" | cut -f 2 -d " ")`
  file=`(echo "$string" | sed -E "s/ {1,}/ /g" | cut -f 9 -d " ")`
  link=`(ls -la /proc/$pid/fd | grep $file | sed -E "s/ {1,}/ /g" | cut -d " " -f 9)`
  > /proc/$pid/fd/$link
 done
