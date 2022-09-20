#!/bin/bash
#getopts при каждом запуске просматривает аргумент $($OPTARG), где $OPTARG при первом запуске =1, т.е. смотрит аргумент $1, и если он
#совподает с перечисленными ключами тогда в указанную переменную ($Opts) записыват ключь, если стоит : значит должен быть аргумент
#после ключа (через пробел), его записывает в $OPTARG, и $OPTIND +1(если подразумевается ":" аргумент у ключа, тогда $OPTARG=$($OPTIND+1) a
#$OPTIND +2  т.е. перескочим следущий аргумент записав его в $OPTARG, и будет просматривать не $2 а $3),т.е при следующем запуске просмотрит $2.
#Если запустить в не цикла тогда просмотрит только $1. :-ие перед перечислением ключей избавляет от вывода ошибки когда не встречаeться
#введёный ключь.Если просматриваемый аргумент не содержит ключей (нет в аргументе "-") тогда getopts перестаёт
#просматривать следующий аргумент и при совпадении присваивать в заданную переменную $Opts.
:
while getopts ":a:bc:" Opts
 do
  echo -e "\n"
  echo $# -количество аргументов.
  echo $* -все аргументы.
  echo $Opts -'$Opts' #Переменная в которую помещаются перечисленные ключи (-a|-b|-c) если встречаються в аргументах.
  echo $OPTARG -'$OPTARG' #Если после ключа стоит : значит у опции/ключа должен быть аргумент (через пробел), он и помещаеться в $OPTARG.
  echo $OPTIND -'$OPTIND' #Номер аргумента который должен быть обработан следующим.
 done
