#!/bin/bash
indir=$1
outdir=$2
#Удаляем / в конце строки если есть, потом добавляем, если не будет / в конце строки, тогда удалять нечего будет просто добавит /.
indir=`(echo $indir | sed -E  's/\/$//g' | sed -E 's/$/\//g')`
outdir=`(echo $outdir | sed -E  's/\/$//g' | sed -E 's/$/\//g')`

infor=webm
outfor=3gp

way_dir=`(echo $way_dir | sed -E  's/\/$//g' | sed -E 's/$/\//g')`
for i in "$indir" "$outdir"
 do
   if [ ! -d "$i" ]
     then echo "$i Проверьте правильность пути.";exit
     elif [ ! -r "$i" ]
         then echo "$i Директория не доступна на чтение.";exit
         elif [ ! -w "$i" -a ! "$i" = "$indir" ]
             then echo "$i Директория не доступна для записи.";exit
   fi
 done


OLDIFS=$IFS
IFS=$'\n'
for infile in `(find "$indir" -maxdepth 1 -type f -iname "*.$infor")`
 do
  #echo $infile
  tmpvar=`(basename "$infile" | sed "s/$infor/$outfor/g")`
  outfile=$outdir$tmpvar
  #echo $outfile
  ffmpeg -v panic -y -i "$infile" -r 24 -s 352x288 -b 400k -acodec aac -strict experimental -ac 1 -ar 32000 -ab 64k "$outfile" && \
  echo -e "\e[0;32m$infile ---> $outfile\e[0m" || echo -e "\e[0;31m$infile ---> $outfile\e[0m"
 done


