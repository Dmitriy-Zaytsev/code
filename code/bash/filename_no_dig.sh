#!/bin/bash
way_dir=${1:-$PWD}
file=; #Найденный файл.
file_new=; #Новое имя файла.
file_expans=".jpg"; #Расширение.
#Поиск файлов с расширением в директории НЕ рекрусивно (.jpg)
#и удаление в именах цифр.
#Внимание если файл будет 0215file1.jpg и 0654_file.jpg один файл затрёт другой.
way_dir=`(echo $way_dir | sed -E  's/\/$//g' | sed -E 's/$/\//g')` #Удаляем / в конце строки если есть, потом добавляем, если не будет / в конце строки, тогда удалять нечего будет просто добавит /.
if [ ! -n "$1" ]
  then echo "Не введён аргумент, поиск будет произведён в "$PWD.""
fi
if [ ! -d "$way_dir" ]
  then echo "Проверьте правильность пути.";exit
  elif [ ! -r "$way_dir" ]
      then echo "Директория не доступна на чтение.";exit
      elif [ ! -w "$way_dir" ]
          then echo "Директория не доступна для записи.";exit
fi
OLDIFS=$IFS
IFS=$'\n' #Когда for получит значения в file от find пробел в имени не будет восприниматься как разделитель новой строки.
for file  in `(find $way_dir -maxdepth 1 -type f -regextype posix-basic -regex ".*[0-9].*\$file_expans")`
   do
    IFS=$OLDIFS
    if [ ! -r "$file" ]
       then echo  "$file - нет прав на чтение."; continue #continue -пропускаем все последующие дейсвия, поднимемся на верх цикла, file принимает следующее значение (строчку).
       elif  [ ! -w "$file" ]
          then echo "$file - нет прав на запись."; continue
          else
              file_new=`(echo $file | sed -E 's/.*[/]//' | sed -E "s/[0-9]|_| //g")` #Удаляем с будущего имени файла, а не со всего пути цифры,_ и пробелы.
              if  [ "$file_new" = "$file_expans" ]
                 then echo "$file - состоит из одних цифр,_ и пробелов."; continue
              fi
    fi
    mv $file $way_dir$file_new
    if [ "$?" = "0" ]
      then echo -e "$file переименован в \n---$file_new"
      else echo "$file не переименован"
    fi
   done
