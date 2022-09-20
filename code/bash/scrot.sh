#!/bin/bash
dir=/tmp/screenshot_scrot
mkdir -p $dir
filename=`(find $dir | wc -l)`.jpg
/usr/bin/scrot $dir/$filename
notify-send -u low "Screenshot $dir/$filename"
