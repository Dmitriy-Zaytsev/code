#!/bin/bash
#copy file error disk
src=$1
dst=$2
format="jpg"

find $src -type f -iname '*.$format'

#if [ -e file ]
# then cp file /somewhere
#fi
