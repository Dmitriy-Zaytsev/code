#!/bin/bash
echo "-15" > /proc/`(ps -ax | grep "postgres " | grep 9.5 | sed -E "s/^ *//g" | cut -f 1 -d " ")`/oom_adj
