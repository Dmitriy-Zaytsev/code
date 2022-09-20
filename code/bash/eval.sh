#!/bin/bash -xv
#Коссвенные ссылки.
unset a b
a=DATA
b=a
echo $b
echo ${!b}

#Т.е два раза интерпретируется 
#1. b=\$$b
#2. b=$a
#3. b=DATA
eval b=\$$b
echo $b

#Нужно переназначать заного при новых значениях переменной.
a=DATA_NEW
echo $b



