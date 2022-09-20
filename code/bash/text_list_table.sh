#!/bin/bash
#Выводит текст в виде таблицы.
##cat ./transl_dict/dict.txt
##wolf#волк,волчара,геймер#0#0
##wol#вол#0#0

file="/home/dima/transl_dict/dict.txt"
header="column1#column2#column3#column4"
fun_format () {
#Максимальная длина строки  отформатированного текста в виде таблицы.
max_string=`((echo "$header";cat "$file")  | sed 's/$\|^/#/g' | sed 's/#/!&!/g' | column -t -s "!" | tr '#' '|' | wc -L)`
#Выводим шапку
#_____________________________________________________________________________
cat /dev/zero | head -c "$max_string" | tr '\0' '_';
echo

#|  column1       |  column2                         |  column3  |  column4  |
(echo "$header"; cat $file) | sed 's/$\|^/#/g' | sed 's/#/!&!/g' | column -t -s "!" | tr '#' '|' | head -n 1

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cat /dev/zero | head -c "$max_string" | tr '\0' '+';
echo
#Выводим сам  файл.
#|  wolf            |  волк                           |  0        |  0        |
(echo "$header"; cat $file) | sed 's/$\|^/#/g' | sed 's/#/!&!/g' | column -t -s "!" | tr '#' '|' | sed '1,+3d'

#Нижний разделитель.
#-----------------------------------------------------------------------------
cat /dev/zero | head -c "$max_string" | tr '\0' '-';
echo
}

fun_format | less
