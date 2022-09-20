#/bin/bash
#Размечает календарт на день(органайзер).
file=./organaizer_day.txt
echo  "=======================================================" > $file
echo \| >> $file
for hours in `(seq 7 1 21)`
do
 for minute in `(seq 00 10 50)`
  do
   [ "$minute" = "0" ] && minute="0$minute"
   echo " ---[$hours:$minute] " >> $file
   echo \| >> $file
  done
done
echo  "=======================================================" >> $file
