#!/bin/bash
dicton='/usr/share/dict/american-english'
trans_sh='./transl_dict.sh'
#dicton='/tmp/123.txt'
log_file='/tmp/random_word.log'
max_cycle="1000"
max_line=`(cat "$dicton" | wc -l)`


> "$log_file"
i=0
###while  [ "$key" != "q" ]
while [ ! "$i" -ge "$max_cycle" ]
 do
   rand_line=$(($RANDOM % $max_line + 1))
   ((i=$i+1))
   echo "Цикл i=$i"
   word=`(sed -n ""$rand_line"p" "$dicton")`

   echo -n "Случайное число:Случайное слово  "
   echo ""$rand_line":"$word"" | tee -a "$log_file"
   $trans_sh -t "$word"

   ##Если бы выпадал рандомно 0.
   ##[ "$rand_line" = "0" ] && continue
   ##read -p "Нажмите q для остановки: " key

  done
echo -e "\n\nПовторы рандомных чисел: "
sort -n $log_file | cut -f 1 -d ":" | sort -h | uniq -c | sed -E "s/ {2,9}//g"

echo -e "\n\nПовторы рандомных слов: "
sort -n $log_file | cut -f 2 -d ":" | sort -h | uniq -c | sed -E "s/ {2,9}//g"

