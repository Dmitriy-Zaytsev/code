#!/bin/bash
! test $# -eq 1 && echo "Введите один аргумент(файл,директоря)." && exit 3
[ ! -e "$1" ] && echo "$1 не существует." && exit 3
file_dir=$1
mount_point=`(stat --printf='%m\n' $file_dir)`
disk=`(mount | grep  "$mount_point " | sed -E "s/(^\S*).*/\1/g")`
#Если символическая ссылка то высести на что ссылаеться.
test -L $disk && stat --printf='%N\n' $disk || echo $disk
