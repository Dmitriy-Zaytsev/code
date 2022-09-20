#no script
#1
var="1 2 3    5 6"; echo $var; echo "$var"
#1 2 3 5 6
#1 2 3    5 6

#2
#echo $a в отличие от "$a" не будет даже перенос строики интерпретировать.
a=`(ls -la)` ; echo $a | cat -n
#1  итого 2812428 -rw-r--r-- 1 dima dima 0 Сен 23 2013 ? 1 2 q X drwxr-xr-x 103 dima dima 24576 Авг 18 10:28 . drwxr-xr-x 3 root root 17 Июл 1 12:54 .. -rw-r--r-- 1 dima dima 0 Авг 26 2013 0. -rw-......

a=`(ls -la)` ; echo "$a" | cat -n
#1  итого 2812428
#2  -rw-r--r--   1 dima dima          0 Сен 23  2013 ?
#3  drwxr-xr-x 103 dima dima      24576 Авг 18 10:28 .
#4  drwxr-xr-x   3 root root         17 Июл  1 12:54 ..
#5  -rw-r--r--   1 dima dima          0 Авг 26  2013 0

#3
var="123 456"; var=`(echo $var | sed 's/ /%20/g')`; echo $var
#or
var="123 456"; var=${var/ /%20}; echo $var #Заменит пробелы на %20
#123%20456
var=a123b123c123; echo ${var#a*2} #Найти начиная с лева (#) и у удалить самую короткую подстроку из совпадающих.
#3b123c123
var=a123b123c123; echo ${var##a*2} #-//- самую длинную -//-.
#3
var=a123b123c123; echo ${var%2*3} #Найти начиная с права (%) и у удалить самую короткую подстроку из совпадающих.
#a123b123c1
var=a123b123c123; echo ${var%%2*3} #-//- самую длинную -//-.
#a1
var="123 456.gz"; echo ${var:4} #Вывести с 4ой позиции(отчёт с 0).
#456.gz
var="123 456.gz"; echo ${var:4:2} #Вывести с 4(отчёт с 0) позиции, 2а символа.
#45
#or
var="123 456.gz"; expr substr $var 5 2 #Тоже самое но через expr и отчёт с 1го.
#45
var="123 456.gz"; echo ${var:(-1)} #С правой стороны.
#z

var=100
speed=${var:+ speed $var} #Если $var есть и не пустая тогда присвоить.
echo $speed
#speed 100

var=;
speed=${var:- speed no} #Если $var нет или она пустая тогда присвоим значение "speed no"
echo $speed
#speed no



#4
IFS='' #Задаём символы разделительи, по умолчанию только пробел.
var1="1,23\456"; var2="123 45.6"; echo $var1; echo $var2; IFS='\,.'; echo -e "\n" ; echo $var1; echo $var2
#1,23\456
#123 45.6
#
#
#1 23 456
#123 45 6

#5
unset a; unset b #Уберём переменные, что бы не вышло заблуждение.
a=abc ; ( b=123; ); echo -e "$a -varA \n$b -varB" #() порождает дочерний процесс(bash), поэтому мы не видим значение присвоенное $b(123) в родительском bash-e(процессе),
                                                  # дочерний процесс унаследует переменные родительского процесса.
#abc -varA
# -varB
unset a; unset b
a=abc ; { b=123; }; echo -e "$a -varA \n$b -varB" #{} не запускает новый процесс, т.е. команда(ы) выполняются в этом же процессе командного интерпретатора.
#abc -varA
#123 -varB


#6
var=123; echo "$var \\  \` "; echo '$var \\  \` '
#123 \  `        #в " " интрепретирует $ \ и `.
#$var \\  \`     # '' строгие кавычки интрепретации не будет, escape-\-тоже строгие кавычки но только для одного символа.

##7
var=1; ((var="$var"+1));echo $var
#2
var=1; var=$(($var+1));echo $var
#2
var=1; var=$((var+1));echo $var
#2
var=1; (( var += 1 ));echo $var
#2
var=1; let "var += 1" ;echo $var
#2
var=1; let "var=var+1" ;echo $var
#2
var=1; var=`(expr $var + 1)` ;echo $var
#2
var="1 2 3 4";varm=($var); echo ${varm[3]}; echo $((varm[3]-1)) #Операциии с масивом. Отчёт элементов в массиве начинаеться с 0.
#4
#3
var="1 2 3 4 a b c";varm=($var); echo ${#varm[@]}; echo $((${#varm[@]}-1)) #От количества элементов в массиве отнимаем 1.
#7
#6




##8
IFS=":"; set var1 var2 var3; echo "\$*--- $*"; echo "\$@--- $@"
#$*--- var1:var2:var3
#$@--- var1 var2 var3

##9
var1= ; var0=${var1:-123}; echo $var0 #var1 объявлена, но пустая (т.е. как будто её нет), поэтому присвоиться 123.
#123
var1= ; var0=${var1-123}; echo $var0 #var1 объявлена хоть и пустая, поэтому var0 примет значение var1.
#


##10
arg="1234 56ab c"; echo ${#arg} #Количество символов в строке.
#11

##11
n=0; var="A B C"; for i in $var; do echo $((n=n+1))-круг цикла; echo $i; done #когда $var не в кавычках символы разделённые пробелами, перебераються поочереди а не строкой. 
#1-круг цикла
#A
#2-круг цикла
#B
#3-круг цикла
#C
n=0; var="A B C"; for i in "$var"; do echo $((n=n+1))-круг цикла; echo $i; done
#1-круг цикла
#A B C

##12
for user in `(cat /etc/passwd | cut -d : -f1)` ; do echo $user; echo "----" ;done
#dpmmgr
#----
#lfcmgr
#----
#nagios
#----
#rtkit
#----
#proftpd
#----


##13-Массив.
#\\n - перевод строки с экранированием (работает при echo -e),
#IFS=',:.' принимаем за разделители ,:. ,
#ip=($ip) записываем всё что в $ip обратно в ip, но уже как массив с нестандартными разделителями(IFS).
ip=172,19:0.1; IFS=',:.' ip=($ip); echo -e  ${ip[0]} \\n${ip[1]} \\n${ip[2]} \\n${ip[3]}
#172
#19
#0
#1

#14-Запись в переменную содержимое файла.
#< - вывод из файла.
var=; var=`<./1.txt`; echo "$var"
var=; var=$(<./1.txt); echo "$var"
var=; var=`cat ./1.txt`; echo "$var"
var=; var=$(cat ./1.txt); echo "$var"

#15-Запись stderr и stdout в файл.
ls -yz >> ./logerr.file #весь stdout запишеться в файл, stderr (не верные ключи) выйдет на терминал.
ls -yz >> ./logerr.file 2>&1 #stderr направили в stdout, и поэтому весь вывод, и ошибки мы увидем в файле.
ls -yz &> ./logerr.file #можно указать что весь stdout и stderr (&>) вывести в файл.
ls -yz 2> ./logerr.file 1> ./logout.file #направить stderr (2>) и stdout (1>) в файлы с перезаписью.
ls ./* 2> ./logerr.file 1> ./logout.file #в этом случае logerr.file будет пустым, а logout.file будет содержать вывод.
ls ./* -yz &>/dev/null #в бездну stdout,stderr.
cat ./1.txt
#a
#b
#co
find ./1.txt | xargs -i -t cat {} | grep c
#cat ./1.txt #stderr (xargs -t).
#co #stdout. grep совпадение.
find ./1.txt | xargs -i -t cat {} 2>&1 | grep c
#cat ./1.txt #stdout. grep совпадение.
#co #stdout. grep совпадение.

#16-exec.
exec ping 127.0.0.1 -c 2
#Завершит текущий bash, и в этом же терминале запустит пинг с pid закрытого bash,
#после того когда ping пройдёт 2-а раза (команда выполнилась), term-инал закроется так как
#у него нет дочерних процессов.

#17-Дескрипторы.
stdin-0-/dev/pts1-in
stdout-1-/dev/pts1-out
stderr-2-/dev/pts1-out
echo "abc" 9>&1 1>&- 1>&9
#abc
9>&1
stdin-0-/dev/pst1-in
stdout-1-/dev/pts1-out
stderr-2-/dev/pts1-out_err
-------9-/dev/pts1-out - всё что будет в 9 дескрипторе будет выводиться туда же куда и stdout.
1>&
stdin-0-/dev/pst1-in
stdout-1- ------- - закрыли stdout.
stderr-2-/dev/pts1-out_err
-------9-/dev/pts1-out
1>&9
stdin-0-/dev/pts1-in
stdout-1-/dev/pts1-out &1(stdout) будет выводиться туда же, куда и &9(вернули всё на свои места).
stderr-2-/dev/pts1-out_err
-------9-/dev/pts1-out
#
#
find ~/1.txt | xargs -i -t cat {}
#cat /home/dima/1.txt #ключ xargs -t выводит в stderr команду с аргументом которая выполняеться.
#a #stdout
#b #stdout
#c #stdout
#stdout выведим в out.txt, stderr выйдет в терминале.
find ~/1.txt | xargs -i -t cat {} 1> out.txt
#cat /home/dima/1.txt #stderr.
cat out.txt
#a
#b
#c
#Перенаправим stderr туда же куда и stdout, т.е. в файл, а не в терминал.
find ~/1.txt | xargs -i -t cat {} 1> out.txt 2>&1
cat out.txt
#cat /home/dima/1.txt
#a
#b
#c
1> out.txt
stdin-0-/dev/pts1-in
stdout-1-out.txt
stderr-2-/dev/pts2-out
2>&1
stdin-0-/dev/pts1-in
stdout-1-out.txt
stderr-2-out.txt
#OR
find ~/1.txt | xargs -i -t cat {} 2> out.txt 1>> out.txt


#18 Результат выполнения команд.
echo "\\\&"
#\\&
echo $(echo "\\\&" ) #То есть всё равно что в строгих кавычках ' '.
#\\&
echo `(echo "\\\&" )`
#\&
#То есть всё равно что в двойных кавычках " ",
#\-ы воспринимается как служебный символ, то есть экранирует другой \.

#Условие в одну строчку.
[ "1" = "1" ] && { echo 1 && [ "1" = "1" ] && echo 2;}
#1
#2
[ "1" = "1" ] && { echo 1 && [ "1" = "2" ] && echo 2;}
#1
#Так как если не выполниться command1 (вернёт не 0), тогда выполниться echo, но echo выполниться
#успешно и условие дальше пойдёт, именно по этому мы поставили отрицание ( ! ).
#{  command1     || ! echo errcom1 } && {  command2     || ! echo errcom2 }
 { [ "1" = "2" ] || ! echo err1 ;} && { [ "1" = "2" ] || ! echo err2 ;}
#err1
:
[ "1" = "1" ]; echo $?
#0
[ ! "1" = "1" ]; echo $?
#1
#Другой пример с выводом в dialog.
{ echo "success1" && [ "1" = "2" ] || ! echo error && echo "success2" ;} | dialog --progressbox 15 15
#success1
#error
{ [ "1" = "1" ]  &&  echo success2 || echo errror2 ;}
#success2
#Если не выполниться первая  [ "1" = "2" ] команда/условие (вернёт не 0), тогда на stdout error1, и следующию команду2 выполнять не будем так как
# echo "error1" вернёт за место 0-я 1-у так как поставили знак отрицания " ! ".
{ [ "1" = "2" ] &&  echo "success1" || ! echo "error1" ;} &&  { [ "1" = "1" ] &&  echo "success2" || ! echo "error2" ;}
#error1

#19 Способы записать в переменную данные с файла.
var=$(<./1.txt)
echo "$var"
#a
#b
#v
var=`(cat ./1.txt)`
echo "$var"
#a
#b
#v



#20 export и дочерние процессы.
var=WIN
echo $var
#WIN
/bin/bash #запустим дочерний процесс.
echo $var
#

#Передадим переменную через export.
exit
echo $var
#WIN
export var
/bin/bash
echo $var
WIN


#21 eval.
var=DIMA var2=var
echo $var2
#var
eval y="$"$var2
echo $y
DIMA
#OR
eval echo "$"$var2
#DIMA
#OR
proc=fun_1
eval time_start_$proc=`(date +%s)`
echo $time_start_$proc
fun_1

