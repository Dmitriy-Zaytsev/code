#!/bin/bash
ru1=word1
ru2=word2
ru3=word3

suffix=1
for ru in ru1 ru2 ru3
do
echo -e "\n--------------------------"
echo "$suffix - текущий суфикс  для переменной."
echo  "$ru - название переменной."
tmp_var=ru$suffix
echo "${!tmp_var} - значение переменной."
declare ru${suffix}=CLEAR
echo ru-$ru1 ru2-$ru2 ru2-$ru3
((suffix=$suffix+1))
done
echo -e "--------------------------"



#for numvar in  `(seq 1 $#)`
# do
#   eval VAR=\$"${numvar}" 
#   echo $VAR
# done

