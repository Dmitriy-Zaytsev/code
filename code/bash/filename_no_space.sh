#!/bin/bash
#Убрать с назаний фалов и директорий пробелы заенив на _, возможен поиск рекурсивно /script.sh /home/dima/dir -r.
way_dir=${1:-$PWD}
list=;
file_or_dir=;
file_or_dir_new=;
norecursive="-maxdepth 1"
:
way_dir=`(echo $way_dir | sed -E  's/\/$//g' | sed -E 's/$/\//g')`
if [ ! -d "$way_dir" ]
  then echo "Проверьте правильность пути.";exit
  elif [ ! -r "$way_dir" ]
      then echo "Директория не доступна на чтение.";exit
      elif [ ! -w "$way_dir" ]
          then echo "Директория не доступна для записи.";exit
fi
echo -en "Поиск будет произведён в $way_dir "
:
if [ "$2" = "-r" ]
   then norecursive=;
        echo "рекрусивно."
   else echo "не рекрусивно."
fi
:
#sort -r - перевернёт вывод для того чтобы вначале шёл путь /home/dima/di r/folder/file 123.txt, а потом /home/dima/di r.
#иначе после смены имени(перемещения) родительской директории find не сможет найти файл file 123.txt.
list=`(find $way_dir $norecursive \( -type f -o -type d \) -iname '* *' | sort -r )`
OLDIFS=$IFS
IFS=$'\n'
for file_or_dir in $list
 do
   IFS=$OLDIFS
   if [ ! -w "$file_or_dir" ]
      then  echo -en "[\e[2;31m"Error"\e[0m] "
            test -d "$file_or_dir" && echo "Директория \"$file_or_dir\" не доступна для записи."
            [ -f "$file_or_dir" ] && echo "Файл \"$file_or_dir\" не доступен для записи."
   echo -en "..." #Отобразить ...
   read -s key #s-не отображать вводимый символ.
   echo -en "\r\c" #Удалить ...
   continue #Вернуться в начало цикла(новое значение file_or_dir).
   fi
#Если файл приводим к виду если директория /home/dima/dir 1/.
   [ -f "$file_or_dir" ] && : # Если являеться файлом тогда ничего не делать (:).
   [ -d "$file_or_dir" ] && file_or_dir=`(echo "$file_or_dir" | sed -E  's/\/$//g' | sed -E 's/$/\//g')`
   object=`(echo "$file_or_dir" | sed  's/^.*\/\(..*$\)/\1/g' | sed  's/\ /_/g')` #Пробелы заменем только в имени файла/директории, а не во всём пути.
   file_or_dir_new=`(echo "$file_or_dir" | echo $(sed 's/\(^.*\/\)..*$/\1/g')$object )` #Получим путь с измененным именем директории или файла, для перемещения.
   echo -en "[ y/n ] "$file_or_dir_new""
   read -sn 1 key
   if [ "$key" = "y" ]
#Если не переместиться то и OK не выведиться а выведит fail, допустим если  вышестоящая директория закрыта для записи, но не файл/директория так как он/она выше проверялся.
     then mv "$file_or_dir" "$file_or_dir_new" &>/dev/null && echo -en "\r\e[2;32m[ \e[0m\e[1;34mOK\e[0m\e[2;32m  ]\e[0m"  || echo -en "\r\e[2;32m[\e[0m\e[1;31mFail\e[0m\e[2;32m ]\e[0m"
     else echo -en "\r\e[2;31m[\e[0m y/\e[2;31mn\e[0m\e[0m\e[2;31m ]\e[0m" #Если нажали всё кроме y.

   fi
   echo ""
 done
