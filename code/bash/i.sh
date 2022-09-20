#!/bin/bash
dir=/home/dima/png/
mkdir $dir -p
last=`(find $dir -iname '*.png' 2>/dev/null | sed -E "s;$dir;;g" | tail -n 1 | sed 's/\.png//g')`
file=$(($last+1))
[[ -z $file ]] && file=1
import $dir$file.png
