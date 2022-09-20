#Имеем скрипт который убивает по имени процесс (killall).

#cat ./sh.sh
#/bin/bash
fun ()
{
prog=$1
kill `(ps -ax 2>/dev/null | grep $prog | grep -v grep | sed 's/^ *//g' | cut -d  " " -f 1)`
}

#Скрипт который перечитывает скрипт 1, запускает sleep в фоне, после чего вызывает функцию (fun) 
прочитанную с sh.sh c переменной sleep, т.е. kill pid(sleep).
#cat ./sh2.sh 
#!/bin/bash
. ./sh.sh &>/dev/null
sleep 999 &>/dev/null &
echo "Run sleep."
#sleep 35
fun sleep
echo "Kill sleep."

#Получим
#./sh2.sh 
Run sleep.
Kill sleep.
./sh2.sh: line 8:  6661 Terminated              sleep 999

#Смотрим вывод ps между "Run sleep" и "Kill sleep." убрав коммент со sleep 35.
#ps -axf
...
5510 ?        S      0:01 xterm
 5512 pts/0    Ss     0:00  \_ bash
 5606 pts/0    S      0:00      \_ sudo su
 5607 pts/0    S      0:00          \_ su
 5615 pts/0    S      0:00              \_ bash
 6682 pts/0    S+     0:00                  \_ /bin/bash ./sh2.sh
 6683 pts/0    S+     0:00                      \_ sleep 999
 6684 pts/0    S+     0:00                      \_ sleep 35
...

#Изменим sh2.sh, так же можем убрать перенаправление в /dev/null.
#cat ./sh2.sh
. ./sh.sh
/bin/bash -c "/bin/sleep 999 &"
sleep 999
echo "Run sleep."
sleep 35
fun sleep
echo "Kill sleep."

#Теперь...
#ps -axf
...
 5510 ?        S      0:01 xterm
 5512 pts/0    Ss     0:00  \_ bash
 5606 pts/0    S      0:00      \_ sudo su
 5607 pts/0    S      0:00          \_ su
 5615 pts/0    S      0:00              \_ bash
 6765 pts/0    S+     0:00                  \_ /bin/bash ./sh2.sh
 6768 pts/0    S+     0:00                      \_ sleep 35
...
 6782 pts/0    S+     0:00 /bin/sleep 999
...

#Запустили sleep в новом экземпляре bash.
#Больше не увидем на выводе инф. о завершении процесса.
#./sh2.sh 
Run sleep.
Kill sleep.


#ps -ax 2>/dev/null | grep sleep
 6840 pts/0    S+     0:00 grep sleep




#OR

#stty tostop
#(sleep 5; echo "FAIL") &
[4] 610

