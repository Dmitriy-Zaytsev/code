#!/bin/bash
! dpkg-query -s "gnumeric" &>/dev/null && echo "Не установлен gnumeric(ssconvert)." && exit
file_in="$1"
file_out="$2"
tmp_file="/tmp/`(basename $file_out)`"
[ ! -f $file_in ] && echo "Нет файла $file_in." && exit 1
[ ! -r $file_in ] && echo "Нет прав на чтение $file_in." && exit 1
[ -f $file_out ] && read -n 1 -p "Переписать файл $file_out(Y/n)" key && { [ "$key" = "n" -o "$key" = "N" ] && exit 1;}
> $file_out
[ ! -w $file_out ] && echo "Нет прав на запись $file_out." && exit 1

ssconvert --export-type=Gnumeric_stf:stf_assistant -O 'separator=;' $file_in $file_out
#sed 's/"//g' -i $file_out #Может понадобиться если переводим xls в csv.
cp $file_out $tmp_file
iconv -f UTF-8 -t CP1251 $tmp_file -o $file_out
rm $tmp_file
