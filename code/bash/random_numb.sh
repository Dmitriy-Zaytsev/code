#!/bin/bash
#Выподает рандомна числа с 1-10 и 29-31.
tmpfile=`(mktemp)`
max=31
greenU='\e[4;32m';rescol='\e[0m'


> $tmpfile
echo $tmpfile

while true
 do

rand=$(($RANDOM % $max + 1))
echo "<<"$rand">>"
if (([[ "$rand" -ge 1 ]] && [[ "$rand" -le 10 ]]) || ([[ "$rand" -ge 29 ]] && [[ "$rand" -le 31 ]]))
then
 grep "^$rand$" $tmpfile && continue 2
 echo  -e "\n"$greenU"$rand"$rescol"\n"
 echo $rand >> $tmpfile
read
fi
done
