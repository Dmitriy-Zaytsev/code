#!/bin/bash

#Если мы не укажем аргумент для ключа b (-b -c), тогда аргументом будет -c,
#что бы этого избежать обнулим $OPTARG и уменьшим номер аргумента для следующий обработки
#($OPTIND) иначе мы -с перепрыгнем. Для этого заведём проверку.
check_arg () {
[[ "$OPTARG" =~ - ]] && unset OPTARG && ((OPTIND=OPTIND-1))
}


while getopts ":ab:c" Opt
 do
  echo -e "\n"
  echo $# -количество аргументов.
  echo $* -все аргументы.
  echo $Opt -'$Opts' #Переменная в которую помещаются перечисленные ключи (-a|-b|-c) если встречаються в аргументах.
  echo $OPTARG -'$OPTARG' #Если после ключа стоит : значит у опции/ключа должен быть аргумент (через пробел), он и помещаеться в $OPTARG.
  echo $OPTIND -'$OPTIND' #Номер аргумента который должен быть обработан следующим.
  check_arg
  case $Opt in
   a ) echo  "Выбран ключь $Opt";;
   b ) echo  "Выбран ключь $Opt и аргумент для него $OPTARG";;
   c ) echo  "Выбран ключь $Opt";;
   * ) echo  "НЕвыбран допустимый ключь  или не указан для него аргумент";;
  esac
 done

#Пример с -q <external vlan> <internal> (q::)
#while getopts "q::" Opts
#  do
#     case $Opts in
#        q) extvlan=$OPTARG;intvlan=${!OPTIND};((OPTIND=OPTIND+1));;
#	 ###OPTIND=3 intvlan=${!OPTIND} = intvlan=$3
#     esac
#  done

