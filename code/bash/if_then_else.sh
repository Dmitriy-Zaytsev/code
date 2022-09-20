#!/bin/bash
##1
#grep -w fc8b.9760.53cd ./1.txt
#if [ $? = 0 ]
#  then echo win
#  else echo error
#fi

##2
#grep -w fc8b.9760.53cd ./1.txt
#if test $? = 0
#  then echo win
#  else echo error
#fi

##3
#if  grep -w fc8b.9760.53cd ./1.txt
#  then echo win
#  else echo error
#fi

##4
#if [ ! -e ~/1.txt ] #Условие если файл ~/1.txt не существует.
# then echo $? #1
#      echo Файла нет.
# else echo $? #0
#      echo Файл есть.
#fi

