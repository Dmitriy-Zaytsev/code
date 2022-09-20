#!/bin/bash
if [ "$#" = "0" ]
  then echo "Введите как минимум один аргумент.";exit
fi
echo -e "Все аргументы:\n$*\n"
while [ -n "$1" ]
do
echo "\$1=$1"
shift #Сдвиг аргументов,$1 принял значение $2,$2 принял $3 и т.д.
sleep 1
done
exit 0
