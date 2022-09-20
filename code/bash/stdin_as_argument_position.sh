#!/bin/bash
fun ()
{
#Если fun не передан первый аргумент тогда message будет то что подали на ввод,
#если ввод через pipe ни чего не передали тогда скрипт не выполниться.
message=${1:-$(</dev/stdin)}
echo $message
}

fun $1


#echo abc | ./stdin_as_argument_position.sh
##abc
#./stdin_as_argument_position.sh 123
##123
#echo abc | ./stdin_as_argument_position.sh 123
##123

