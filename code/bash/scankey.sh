#!/bin/bash
old_tty_setting=`(stty -g)` #запоминаем текущие настройки терминала.
echo start
stty -icanon -echo #для того чтобы терминал не выводил введёные символы.
dd bs=1 count=15 1> ~/keyscan.txt 2> /dev/null #считать с ввода за раз 1 байт по 15 раз, вывод в файл, ошибки в бездну.
stty "$old_tty_setting" #востоновим настройки.
