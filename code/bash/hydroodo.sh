#!/bin/bash
#export - перманентно запомнит  значения переменных, до закрытия терминала/сеанса.
#export WINEARCH="win64" WINEPREFIX="~/.wine64" LC_ALL="ru_RU.utf8" LANG="ru_RU.utf8"

#Разово запустим программу со значениями этих переменных.
WINEARCH="win64" \
WINEPREFIX=~/.wine64 \
LC_ALL="ru_RU.utf8" \
LANG="ru_RU.utf8" \
wine64 "/home/dima/.wine64/drive_c/Program Files/hydroodo/hydroodo.exe"

#WINEARCH,WINEPREFIX - если запускать как 32bit-ую, выходит ошибка "List index out of bounds (-1)".
#LC_ALL,LANG -  если запустить как LC_ALL=C(английский), ошибка "'0,22' is not a valid floating point value".
