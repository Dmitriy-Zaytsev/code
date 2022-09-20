#!/bin/bash
if [ "$#" != "2" ] || [ "$1" = "-h" ]
 then echo "Введите $0 {C|M} ammount" && exit 1
fi
case $1 in
 [C,c,M,m] ) ;;
 * ) echo "Не допустимый 1-ый аргумент" ; exit 1;;
esac
case $2 in
 [0-9][0-9]|[1-9] ) ;;
 * ) echo "Не допустимый 2-ый аргумент" ; exit 1;;
esac
sort=$1 #Сортировка по CPU|MEMORY.
amount=$2 #Количество выводимых процессов.
while true
 do
   date=`(date "+%d/%m/%y %H:%M:%S:%N")`
   toplist=`(top -n 1 -b)`
   header=`(echo "$toplist" | sed -n '1,7p')`
   list=`(echo "$toplist" | sed -n '1,7!p')`
#Cортировка по cpu или mem, и вывод n($2) строк.
   case $sort in
    [C,c] )listSort=`(echo "$list" |  sort -h -k 9 -r | head -n $amount)`;;
    [M,m] )listSort=`(echo "$list" |  sort -h -k 10 -r | head -n $amount)`;;
   esac
#echo "$listSort"
   echo -e "$date\n$header\n.....\n$listSort\n......\n\n"
   sleep 1 #Интервал снятия top =1сек.
 done
