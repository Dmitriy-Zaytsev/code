#!/bin/bash
path=${1:-/tmp/screenshot_import/}
mkdir -p /tmp/screenshot_import/
name=${2:-image}
path=`(echo $path | sed 's/\/$//g' | sed 's/$/\//g' )`
echo $path
! test -d "$path" &&  echo "Указана не верная директория." && exit
! test -w "$path" &&  echo "Директория не доступна на запись." && exit
i=1
#как пример.
#echo {1..9} | tr ' ' '\n' | xargs -i import -quality 100 /tmp/map/zjb/{}.jpg
while true
 do
    import $path$name-$i.jpg -quality 100 && echo "[ ready ]:$path$name-$i.jpg"
   (( i += 1 ))
   echo ".......enter key <z>........"
   while true
    do
      read -sn 1 key
      [ "$key" = "z" ] && break
    done
 done
