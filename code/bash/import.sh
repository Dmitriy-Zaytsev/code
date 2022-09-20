#!/bin/bash
dir=/home/dima/png/
mkdir $dir -p
/usr/bin/import "$dir`(date +%F-%H-%M-%S)`.png"
