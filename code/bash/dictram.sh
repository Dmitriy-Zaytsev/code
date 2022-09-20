#!/bin/bash
     # bash --version
     # GNU bash, version 4.2.37(1)-release (x86_64-pc-linux-gnu)
SLOVAR=~/.dictram/dictionary.txt #словарь
lines1="" #варианты перевода
lines2=""
lines3=""
num_trans_en_ru="" #количество верных введёных переводов
num_line="" #строка в словаре которая содержит слово
yesno=no #выбор
key="" # EscEnter
i=1 #Счетчик
auto_chan=4 # Смена слова
tmp1="" # Переменные для вывода команд
tmp2=""
:
ls -la ~/.dictram/ > /dev/null 2> /dev/null
if [ $? != 0 ]
  then mkdir ~/.dictram/
fi
ls -la $SLOVAR > /dev/null 2> /dev/null
if [ $? != 0 ]
  then echo "Будет создан файл в "$SLOVAR""; > $SLOVAR
fi
:
if  [ -z $1 ]
  then echo "Не верные введённые аргументы" # Допустим если ни один аргумент не введён
       echo "Воспользуйтесь "$0" -h или "$0" help"
       exit
fi
if [  $1 = "add" -o $1 = "-a" ] && [ $2 = "en" ] && [ -z != $3 ]
  then case $3 in
        *[!=a-z]* ) echo "Указанно не верное слово для занесения в словарь"; exit;;
       esac
  cat $SLOVAR | grep -w -i "$3":
  if [ $? = 0 ]
    then  echo "Слово уже имееться в словаре, удалить старое и записать новое (yes/NO)?"
          read yesno
          if [ $yesno != "yes" ]
             then exit
             else sed -i "/^$3:/d" "$SLOVAR"
          fi
  fi
  yesno=yes
  echo "Введите перевод en-ru"
  num_trans_en_ru=0; read line1
  grep -iE [:.,]$line1[,.] $SLOVAR > /dev/null
  if [ $? = 0 ]
    then echo ""$line1" являеться вариантом перевода слов"
         grep -iE [:.,]$line1[,.] $SLOVAR
         echo "Записать вариант перевода (YES/no)"
         read yesno
         case $yesno in
          yes ) echo "Вариант перевода записан для "$3"";;
          no ) echo "Вариант перевода не записан для "$3"";line1="";;
          * ) echo "Вариант перевода записан по умолчанию для "$3"";;
         esac
  fi
  yesno=yes
  if [ -z != $line1 ]
    then num_trans_en_ru=1
         read line2;
         grep -iE [:.,]$line2[,.] $SLOVAR > /dev/null
         if [ $? = 0 ]
           then echo ""$line2" являеться вариантом перевода слов"
                grep -iE [:.,]$line2[,.] $SLOVAR
                echo "Записать вариант перевода (YES/no)"
                read yesno\n
                case $yesno in
                 yes ) echo "Вариант перевода записан для "$3"";;
                 no ) echo "Вариант перевода не записан для "$3"";line2="";;
                 * ) echo "Вариант перевода записан по умолчанию для "$3"";;
                esac
         fi
  fi
  if [ -z != $line2 ]
    then num_trans_en_ru=2
         read line3
         grep -iE [:.,]$line3[,.] $SLOVAR > /dev/null
         if [ $? = 0 ]
           then echo ""$line3" являеться вариантом перевода слов"
                grep -iE [:.,]$line3[,.] $SLOVAR
                echo "Записать вариант перевода (YES/no)"
                read yesno
                case $yesno in
                 yes ) echo "Вариант перевода записан для "$3"";;
                 no ) echo "Вариант перевода не записан для "$3"";line3="";;
                 * ) echo "Вариант перевода записан по умолчанию для "$3"";;
                esac
         fi
  fi
  if [ -z != $line3 ]; then num_trans_en_ru=3
  fi
:
  case $line1  in
   *[a-z]*|*[0-9]* ) echo "Не верный 1 вариант перевода слова "$3""; line1="";;
  esac
  case $line2  in
   *[!=а-я]* ) echo "Не верный 2 вариант перевода слова "$3""; line2="";;
  esac
  case $line3  in
   *[!=а-я]* ) echo "Не верный 3 вариант перевода слова "$3""; line3="";;
  esac
  if [ -z $line1 ] && [ -z $line2 ] && [ -z != $line3 ]
    then  line1=$line3; num_trans_en_ru=1; echo "Будет записан только 3 вариант перевода";
    elif [ -z $line1 ] && [ -z != $line2 ] && [ -z $line3 ]
        then line1=$line2; num_trans_en_ru=1;echo "Будет записан только 2 вариант перевода";
        elif [ -z != $line1 ] && [ -z $line2 ] && [ -z $line3 ]
            then num_trans_en_ru=1; echo "Будет записан только 1 вариант перевода";
            elif [ -z != $line1 ] && [ -z != $line2 ] && [ -z $line3 ]
                then num_trans_en_ru=2;echo "Будет записан только 1 и 2 вариант перевода";
                elif [ -z != $line1 ] && [ -z $line2 ] && [ -z != $line3 ]
                    then line2=$line3; num_trans_en_ru=2;echo "Будет записан только 1 и 3 вариант перевода";
                    elif [ -z $line1 ] && [ -z != $line2 ] && [ -z != $line3 ]
                        then line1=$line2; line2=$line3; num_trans_en_ru=2;echo "Будет записан только 2 и 3 вариант перевода";
                        elif [ -z "$line1" ] && [ -z  "$line2" ] && [ -z  "$line3" ]
                             then  num_trans_en_ru=0
  fi
:
:
  case "$num_trans_en_ru" in
   0 ) echo "Перевод не введён"; exit;;
   1 ) echo ""$3":"$line1"."  >> $SLOVAR;;
   2 ) echo ""$3":"$line1","$line2"." >> $SLOVAR;;
   3 ) echo ""$3":"$line1","$line2","$line3"." >> $SLOVAR;;
  esac
:
  echo "Добавленно en слово"
  cat $SLOVAR | grep -w -i $3
  exit
fi
:
if [ $1 = "del" -o $1 = "-d" ] && [ $2 = "en"  ] && [ -z != $3 ]
  then case $3 in
        *[!=a-z]* ) echo Неверно введено удаляемое слово ; exit;;
       esac
       cat $SLOVAR | grep -w -i "$3"
       case  $? in
        [!=0] ) echo "Слова "$3" нет в словаре"; echo "Список слов в которых присутствует "$3""; cat $SLOVAR | grep -i $3; exit;;
        0 ) echo "Удалить из словоря "$3" (yes/NO)?"; read yesno;;
       esac
       if [ $yesno == yes ]
         then sed -i "/^$3/d" "$SLOVAR"; echo "Было удаленно слово "$3""
       fi
       exit
fi
:
if [ "$1" = "show" -o "$1" = "-s" ]
  then  if [ -z $2 ]
          then echo  "Будут показаны случайные строки со словоря "$SLOVAR""
               num_line=`(cat -n $SLOVAR | tail -n 1 | cut -f1)`
               if [ -z $num_line ]
                 then echo "Словарь пуст";exit
               fi
               echo  "Количество строк в словаре "$num_line""
               read -t 8 -p "Введите автоматическое время смены слов в сек " auto_chan
               case $auto_chan in
                 *[!=0-9]* ) echo "Ошибка, не числовой ввод"; exit;;
                  * ) auto_chan=4;;
                esac
               echo "Чтобы завершить нашмите - q\n, продолжить - Enter"
               ((num_line=num_line+1))
               while  [ "$key" != "q" ]
                do
                 rand_line=$(($RANDOM % $num_line))
                 if [ $rand_line -ne 0 ]
                   then
                        echo -n -e "\e[0;32m`(cat -n $SLOVAR | grep -w $rand_line | cut -f2 | cut -d : -f1)`\e[0m - \e[0;33m`(cat -n $SLOVAR | grep -w $rand_line | cut -f2 | cut -d : -f2 )`\e[0m "
                        read -es -t $auto_chan key
                        echo -en '\r                                                       \r'
                 fi
                done
        exit
        fi
        if [ -n $2 ]  && [ "$3" = "-e" -o "$3" = "exa" ]
          then num_line=`(grep  -w $2 $SLOVAR | cat -n | tail -n 1 | cut -f1)`
               if [ -z $num_line ]
                then echo "Совпадений нет";exit
               fi
               echo  "Количество  совпадений в словаре "$num_line""
               tmp1=`(cat $SLOVAR | grep -w  $2 | grep  -n $2  | cut -d : -f1,2)`
               tmp2=`(cat $SLOVAR | grep -w $2 | grep  -n $2 | cut -d : -f1,3)`
               #echo "$tmp1"
               #echo "$tmp2" #В таком виде выводит построчно всё что было записано
               #echo $tmp1 #Выведит всё в одну строку
               while [ "$num_line" != "0" ]
                do
                 echo  -en "\e[0;32m`(echo "$tmp1" | grep -w $num_line | cut -d : -f2)`\e[0m"
                 echo -en " - "
                 echo  -e "\e[0;33m`(echo "$tmp2" | grep -w $num_line | cut -d : -f2)`\e[0m"
                 ((num_line=num_line-1))
                done
        fi
        if [ -n $2 ] && [ -z $3  ]
          then num_line=`(grep  $2 $SLOVAR | cat -n | tail -n 1 | cut -f1)`
               if [ -z $num_line ]
                then echo "Совпадений нет";exit
               fi
               echo  "Количество  совпадений в словаре "$num_line""
               tmp1=`(cat $SLOVAR | grep  $2 | grep  -n $2  | cut -d : -f1,2)`
               tmp2=`(cat $SLOVAR | grep  $2 | grep  -n $2 | cut -d : -f1,3)`
               #echo "$tmp1"
               #echo "$tmp2" #В таком виде выводит построчно всё что было записано
               #echo $tmp1 #Выведит всё в одну строку
               while [ "$num_line" != "0" ]
                do
                 echo  -en "\e[0;32m`(echo "$tmp1" | grep -w $num_line | cut -d : -f2)`\e[0m"
                 echo -en " - "
                 echo  -e "\e[0;33m`(echo "$tmp2" | grep -w $num_line | cut -d : -f2)`\e[0m"
                 ((num_line=num_line-1))
                done
          fi
echo "Не верные введённые аргументы" # Допустим если  show work sdfjsf
echo "Воспользуйтесь "$0" -h или "$0" help"
exit
fi
:
if [ "$1" = "mem" -o "$1" = "-m" ]
   then if [ -z $2 ]
          then echo  "Будут показаны поочерёдно en потом ru "$SLOVAR""
               num_line=`(cat -n $SLOVAR | tail -n 1 | cut -f1)`
               if [ -z $num_line ]
                 then echo "Словарь пуст";exit
               fi
               echo  "Количество строк в словаре "$num_line""
               ((num_line=num_line+1))
               read -t 8 -p "Введите автоматическое время открытия перевода " auto_chan
               case $auto_chan in
                *[!=0-9]* ) echo "Ошибка, не числовой ввод"; exit;;
                * ) auto_chan=6;;
               esac
               echo "Чтобы завершить нашмите - q\n, продолжить - Enter"
               while  [ "$key" != "q" ]
                do
                 rand_line=$(($RANDOM % $num_line))
                 if [ $rand_line -ne 0 ]
                   then
                        echo -n -e "\e[0;32m`(cat -n $SLOVAR | grep -w $rand_line | cut -f2 | cut -d : -f1)`\e[0m - "
                        read -es -t $auto_chan key
                        echo -n -e "\e[0;33m`(cat -n $SLOVAR | grep -w $rand_line | cut -f2 | cut -d : -f2)`\e[0m"
                        read -es -t $auto_chan key
                        echo -en '\r                                                       \r'
                  fi
                done
        exit
        fi
        if [ "$2" = "tng" ]
          then echo  "Будут показаны en слова со словоря "$SLOVAR", нужно ввести один из вариантов перевода"
               num_line=`(cat -n $SLOVAR | tail -n 1 | cut -f1)`
               echo  "Количество строк в словаре "$num_line""
               ((num_line=num_line+1))
               read -t 8 -p "Введите автоматическое время открытия перевода " auto_chan
               case $auto_chan in
                *[!=0-9]* ) echo "Ошибка, не числовой ввод"; exit;;
                * ) auto_chan=6;;
               esac
               echo "Чтобы завершить нашмите - q\n, продолжить - Enter"
               while  [ "$key" != "q" ]
                do
                 rand_line=$(($RANDOM % $num_line))
                 if [ $rand_line -ne 0 ]
                   then
                        echo -n -e "\e[0;32m`(cat -n $SLOVAR | grep -w $rand_line | cut -f2 | cut -d : -f1)`\e[0m - "
                        read -es -t $auto_chan key
                        echo -n -e "\e[0;33m`(cat -n $SLOVAR | grep -w $rand_line | cut -f2 | cut -d : -f2)`\e[0m"
                        read -es -t $auto_chan key
                        echo -en '\r                                                       \r'
                 fi
                done
        exit
        fi
fi
echo "Не верные введённые аргументы"
echo "Воспользуйтесь "$0" -h или "$0" help"
