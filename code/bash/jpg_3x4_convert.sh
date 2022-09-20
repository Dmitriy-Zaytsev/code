#!/bin/bash
##!/bin/bash -x - для отладки.
#Ищет файла заканчивающиеся на .jpg, конверитрует в формат 3x4 (300x400), и сжимает если размер больше 100KB,
#сохраняя в этуже директорию с добавлением New и изменением расширения.
dpkg-query -s imagemagick &>/dev/null || { echo "Не установлен пакет imagemagick."; exit 1;}
dpkg-query -s libfile-mimeinfo-perl &>/dev/null || { echo "Не установлен пакет libfile-mimeinfo-perl."; exit 1;}
quality=100
path=${2:-`(pwd)`}
fast=$3

CONVERT ()
{
qual=$quality
echo "***********"
[ `(mimetype "$file" | cut -f 2 -d ":" | sed -e s'/\(.*\)\/\(.*\)/\1/g' -e 's/^ *//g')` = "image" ] || return 1
key=n
[ ! "$fast" = "fast" ] && \
{ read -s -r -n 1 -p "Change $file(y/N)?" key
[ ! "$key" = "y" ] && { echo -e "\n" && return 0;};}
oldformat=`(mimetype "$file" | cut -f 2 -d ":" | sed -e s'/\(.*\)\/\(.*\)/\2/g' -e 's/^ *//g')`
predpi=$(convert "$file" -print "%wx%h\n" /dev/null)
presize=`(du -sh "$file" | cut -f1)`
newfile=`(echo "$file" | sed -E 's/(.*)\..*/\1NEW.jpg/g')`
newfile2=`(echo "$file" | sed -E 's/(.*)\..*/\1.jpg/g')`
#-resize 300x400^ -сжимаем изображение сохраняя пропорции(^), получаем например 300x468
#-gravity center -extent 300x400 -с центра оставляем 300 на 400, т.е. обрезаем лишнии края, в нашем случае низ и верх.
#сохраняем без потерь в тот же файл.
[ ! -w `(dirname "$newfile")` ] &&  echo -e "\nDirectory unwritable." && continue
convert -resize 300x400^ -gravity center -extent 300x400 -quality $qual% "$file" "$newfile"
#Будем уменьшать качество до 0 пока файл больше 100KB.
while [ `(du -s "$newfile" | cut -f 1)` -gt "100" -a "$qual" -gt "0" ]
do
 ((qual=$qual-5))
  convert -quality $qual% "$newfile" "$newfile"
done
rm "$file"
mv "$newfile" "$newfile2"
echo -e "\n`(basename "$file")`--->`(basename "$newfile2")`"
echo "$oldformat--->`(mimetype "$newfile2" | cut -f 2 -d ":" | sed -e s'/\(.*\)\/\(.*\)/\2/g' -e 's/^ *//g')`"
echo "$predpi--->`(convert "$newfile2" -print "%wx%h\n" /dev/null)`"
echo "$presize--->`(du -sh "$newfile2" | cut -f1)`"
}


LIST ()
{
echo "***********"
echo "$file"
echo "`(mimetype "$file" | cut -f 2 -d ":" | sed -e s'/\(.*\)\/\(.*\)/\2/g' -e 's/^ *//g')`"
echo "`(convert "$file" -print "%wx%h\n" /dev/null)`"
echo "`(du -sh "$file" | cut -f1)`"
}


list ()
{
[ -f "$path" ] && file="$path" && LIST && echo "***********" && exit 0
OLDIFS=$IFS
IFS=$'\n'
for file in `(find "$path" -type f)`
do
LIST
done
echo "***********"
IFS=$OLDIFS
}

conv ()
{
[ -f "$path" ] && file="$path" && { CONVERT || exit 1;} && echo "***********" && exit 0
OLDIFS=$IFS
IFS=$'\n'
for file in `(find "$path" -type f)`
do
CONVERT || continue
done
echo "***********"
IFS=$OLDIFS
}


[ "$1" = "list" ] && { list;exit 0;}
[ "$1" = "convert" ] && { conv; exit 0;}
echo  "$0 list|convert [path]" && exit 1
