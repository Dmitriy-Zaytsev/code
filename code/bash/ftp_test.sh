#!/bin/bash
count=50
while [[ "$count" > "0" ]]
  do
    echo $count
    echo "get 20mb.bin /tmp/"$count".bin" | ftp 192.168.33.6 &>/dev/null &
    sleep 0.5
    count=$((count-1))
  done
wait
