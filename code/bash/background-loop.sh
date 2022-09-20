#!/bin/bash
r="---"
echo start-1
for i in `(seq 1 50)`
 do
   echo $i
   echo $r
 done &
echo start-2
 for i in a b c d
 do
   echo $i
   echo $r
 done
echo $! #PID последнего процесса запущенного в фоне.
echo $$ #PID самого процесса-сценария.
wait #Ждёт пока все процессы которые он запустил не закончат свою работу.
#kill $$
#kill $!
