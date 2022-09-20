#!/bin/bash
fun ()
{
echo "start 1"
[ "$1" = "1" ] && return 11
echo "start 2"
[ "$1" = "2" ] && return 22
echo "start 3"
[ "$1" = "3" ] && return 33

echo "start 4"
[ "$1" = "1" ] && return 44
}
fun $1
echo $?


