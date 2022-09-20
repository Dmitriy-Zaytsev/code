#!/bin/bash -r
##or
###!/bin/bash
##set -r
#Ограниченный режим bash.
echo "Текущий каталог $PWD."
echo "cd .."
cd .. #Смена текущего каталога запрещено.
echo "Текущий каталог $PWD."
echo "........."
echo "Командный интерпретатор = $SHELL"
echo "SHELL="/bin/expect""
SHELL="/bin/expect" #Смена ком.интерпр.
echo "Командный интерпретатор = $SHELL"
echo "........."
echo "ls -l > stdout.txt"
ls -l > stdout.txt #Перенаправление вывода.
echo "cat stdout.txt"
echo "........."
echo "/bin/ip route"
/bin/ip route #Вызов утилиты в названии которой "/", т.е. возможно нет в $PATH.
echo "........."
echo "exec /bin/bash" #Завершение текущего bash и запуск другого процесса с тем же pid.
exec bash
echo "........."
