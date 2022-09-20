#!/bin/bash
#Вывести числа от 1 до 22, кроме 3 и 11.Как только дойдёт до a=22 то прервать цикл.
a=0
limit=22

while [ $a -lt $limit ]
 do
  ((a=a+1))
    if [ "$a" = "3" ] || [ "$a" = "11" ]
      then echo "Переход в начало цикла"
      continue
    fi
    if [ "$a" = "22" ]
      then echo "Цикл прерван break т.к. a=22"
      break
    fi
   echo $a
 done

