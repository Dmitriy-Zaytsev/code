#!/bin/bash
echo "FREE:`(free -h | sed -E 's/\ {1,15}/ /g' | cut -d " " -f 4 | sed '2p' -n)`"
sync
echo 1 > /proc/sys/vm/drop_caches
echo 2 > /proc/sys/vm/drop_caches
echo 3 > /proc/sys/vm/drop_caches
echo "FREE:`(free -h | sed -E 's/\ {1,15}/ /g' | cut -d " " -f 4 | sed '2p' -n)`"
