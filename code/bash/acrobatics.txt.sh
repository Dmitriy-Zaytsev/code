/##1
#Находим символы .,:;- и пробел и заменяем их на не на что; пото находим 2 символа от 0-9 или A-F и добовляем : ; находим : в конце строки ($) и меняем не на что.
var="11,2E.F:344.5 5;6-6"; var=`(echo $var | sed -e 's/[." ",:;-]//g; s/[0-9,A-F][0-9,A-F]/&:/g; s/:$//')`; echo $var
#11:2E:F3:44:55:66

##2
#Удалим всё кроме (заменим не на что) 0-9,a-f и A-F.
var="123fdFDkKl123  yT"; echo $var | sed  -e  's/[^0-9,a-f,A-F]//g'
#123fdFD123

##3
#Узнаем какой псевдо терминал у нас запущен.
ps -p `(echo $$)` | grep pts | cut -f3 -d " "

##4
#cat воспримет результат/вывод команды find как аргументы, и выведет содержимое файлов.
cat `(find ./2/ -iname '*.txt*')`
#11111
#22222
#cat выведит то что ему послали на stdin, а там только название файлов, а не их содержимое поэтому...
find ./2/ -iname '*.txt*' | cat
#./2/1.txt
#./2/2.txt
#...передадим название файла как аргумент, то есть вывод find становиться вводом а потом передаётся как аргументы для cat.
find ./2/ -iname '*.txt*' | xargs cat
#11111
#22222
#or
#-i передаёт аргумент cat-у в положение где указанна {},
#-t покажет выполненые команды, но выведит их в stderr а не в stdout, но мы их увидим так как терминал считывает/показывает нам всё что на stderr и stdout.
find ./2/ -iname '*.txt*' | xargs -i -t cat {}
#cat ./2/1.txt
#11111
#cat ./2/2.txt
#22222
#Если мы хотим перенаправить и выполняемые фалы которые подаються на stderr(откуда потом считывает терминал, также с stdout),
#нам будет не достаточно перенаправить в файл только вывод "1>"или">", перенаправим всё что на stderr и stdout "&>".
find ./2/ -iname '*.txt*' | xargs -i -t cat {} &> stdout_and_stderr.txt
cat ./stdout_and_stderr.txt #посмотрим что записали.
#cat ./2/1.txt
#11111
#cat ./2/2.txt
#22222
#Поиск рекрусивно по файлам  заканчивающиеся на txt слово tar в начале строки с цетным выводом совпадения и названия файла.
sudo find  ./ -type f -iname '*txt' -exec grep ^tar --color -H {} \;
#./transfer_OS.txt:tar -xvzpf /mnt/disk_of/techn_backup.tar.gz
#./transfer_OS.txt:tar -xvzpf /mnt/tar/techn_backup.tar.gz


##5
#Каждые 10 секунд watch запустит то что в "", то есть выведим логи и запишем в 1.txt с перезаписью.
watch -n 10 "cat /var/log/syslog  > 1.txt"


##6
var="abcdef 123456"; expr substr "$var" 1 3
#abc
#OR
echo "abcdef 123456" | xargs -i expr substr {} 1 3
#abc

##7
#xargs считывает (по умолчанию) с stdin и передаёт как аргумент утилите echo.
xargs -i echo {}
#sdfsdfdsf #Вводим.
#sdfsdfdsf #Вывод echo.

##8
#Не всегда файлы соответстуют расширению, выход есть.Если grep-у поставить -v тогда произайдёт инверсия.
find /mnt/2/downloads/ | xargs -i file {} --mime-type | grep audio
#/mnt/2/downloads/Легенды про... - Старый добрый рэпчик (2014).mp3: audio/mpeg
#/mnt/2/downloads/Легенды Про... - Фонари.mp3: audio/mpeg
#/mnt/2/downloads/Zambezi - Лучше бы.txt: audio/mpeg


##9
#Запишет в файл вывод даты и os.
(date && uname -a) > linux_and_date.txt

##10
#Убираем цифры и пробелы.
echo "abc1235645 def.txt" | sed -E s/[0-9]\|' '//g
#abcdef.txt

##11
#sed
echo abcdef | sed -E s/[^cba]/1/g
#abc111 #заменнит если символ НЕ ([^..]) будет являться c,b или а.
cat comment.txt
##
#:
#if #comment.
#  then
#  else
#fi #comment.
#echo Win\#
#echo 'win #' #Commment.
#echo Win\:
#echo 'win :'
cat comment.txt | sed -E  -n /then/,/\(ddd\|echo\)/p
#Вывести строки от then до ddd, или от then до echo.
#(-n) -не будет выводить весь полученный текст,
#а ключь (p) выведет то что ему задали(результат работы).
#  then
#  else
#fi #comment.
#echo Win\#
cat comment.txt | sed -E  /then/,/\(ddd\|echo\)/s/fi/abc/
#В тех же найденных строках, произведём замену if на abc,
#уберём (-n) что бы увидеть полученный текст и (p) что бы
#не видеть повторный вывод что он заменил.
##
#:
#if #comment.
#  then
#  else
#abc #comment.
#echo Win\#
#echo 'win #' #Commment.
#echo Win\:
#echo 'win :'
sed '2254,2258d' ./swNCtuips.txt
#Удалим с 2254 по 2258 строку.
#Заеним в строке где есть "/ " но нет в начале # на .... \S*-любое количество символов кроме пробелов.
#Если добавить -i тогда изменения внесуться в файл.
sed "/^[^#].*\/ /s/\(UUID=\)\S*\(.*\)/\1ABC23456-ABC \2/g" /etc/fstab
...
UUID=ABC23456-ABC  /               ext4    errors=remount-ro 0       1
...
#Добавить (i) строки выше /var/log/syslog в которой первый символ не # две строки,
#если надо ниже тогда (a), -i для изменения файла.
sed -E "/^[^\#].*\/var\/log\/syslog/ i STRING1\nSTRING2" /etc/rsyslog.conf

##12
#grep
echo "123abc12def1233" | grep -E "123*"
#123abc12def1233 #* - следущий символ МОЖЕТ НЕ присутствовать может повторяться n раз.
echo "123abc12def1233" | grep -E "123+"
#123abc12def1233 #+ - следущий символ ДОЛЖЕН присутствовать и может повторяться n раз.
echo "abc abc123" | grep -w -E "abc(123)*"
#abc abc123 #Аналогично но за последний символ примем 123.
echo "abc abc123" | grep -w -E "abc(123)+"
#abc abc123 #Аналогично но за последний символ примем 123.

##13
#{min,max} количество повторения предидущего символа.
echo "1aaaaa2" | grep -E "1a{1,5}2"
#1aaaaa2
echo "1aaaaa2" | grep -E "1a{1,}2"
#1aaaaa2
echo "1aaaaa2" | grep -E "1a{,5}2"
#1aaaaa2

##14
#Подсчёт количество строк в файле.
cat ./1.txt
#a vb
#
#ifk
#123
#j7
#
#sdf
egrep -c "." ./1.txt #Подсчёт строк где содержиться хоть один символ (значит пустые считать не будет).
#5
egrep -c ".*" ./1.txt #Количество всех строк в том числе и пустых.
#7
egrep -n ".*" ./1.txt | cut -d : -f1 | tail -n 1 #Менее удобный и медленный способ.
#7
wc -l ./1.txt #Самый лёгкий и быстрый способ.
#7 ./1.txt

##15
#Шифрует(заменяет) букву от a-z на z-a, `(echo {z..a} | sed -E 's/ //g' - выводит от z до a без пробелов.
echo work | tr 'a-z' `(echo {z..a} | sed -E 's/ //g')` #но такой способ не переписыват много (p,h,t,l...) букв.
#dlip
echo "http://linkmeup.ru" | tr "`(echo {a..z})`" "`(echo {z..a})`" #шифруем.
#sggk://ormpnvfk.if
echo "sggk://ormpnvfk.if" | tr "`(echo {z..a})`" "`(echo {a..z})`" #дешифруем.
#http://linkmeup.ru
echo -e {a..z} \\n`(echo {z..a})` #увидим какя буква как шифруеться.
#a b c d e f g h i j k l m n o p q r s t u v w x y z
#z y x w v u t s r q p o n m l k j i h g f e d c b a


#16
#tee всё что попало на ввод перенаправит в файл и выведит на вывод,
#если не будет перенаправления (пайпа).
echo "a b c d e f" | tee ~/test.txt  | sed -E 's/ //g'
#abcdef
cat ./test.txt
#a b c d e f

#17
fuser /dev/ttyS0 -k #Убьёт процесс который использует /dev/ttyS0. 

#18
#Вывести строчки с eth0 и конец строки или :2.
echo -e "eth0:1\neth0\neth0:2" | grep -E eth0\($\|:2\)
#eth0
#eth0:2

#19
#Сравнение скорости tftp и ftp.
du -h /srv/ftp/ES3528-52M/ES3528_52M_opcode_V1.4.20.11.bix
#4,9M    /srv/ftp/ES3528-52M/ES3528_52M_opcode_V1.4.20.11.bix

time tftp 127.0.0.1 <<End-Of-Sesget
get ES3528-52M/ES3528_52M_opcode_V1.4.20.11.bix
quit
End-Of-Sesget
#tftp> Received 5095459 bytes in 0.2 seconds
#tftp>
#real    0m0.224s
#user    0m0.072s
#sys     0m0.136s

time ftp -n 127.0.0.1 <<End-Of-Sesget
user anonymous anonymous
binary
cd ES3528-52M
get ES3528_52M_opcode_V1.4.20.11.bix
quit
End-Of-Sesget
#real    0m0.044s
#user    0m0.000s
#sys     0m0.020s

#20
#Секундомер.
#time read
введём enter.
#real    0m1.037s #Покажет время, исполнение команды read. read - ждать ввода с stdin.
#user    0m0.000s
#sys     0m0.000s

#21
#sudo !! через алиас.
alias wtf='sudo `(history -p \!\!)`' #где !! - ключи для history.

#22
#Пример отображения загрузки SystemV.
#civis-скрыть курсор,hpa 0 -встать на позицию 0,setaf 2 - красный, op - обычный цвет, cnorm - отобразить курсор,sc/rc - сохранить/восстановить положение курсора.
tput sc;echo -n [....]; sleep 1; tput civis;tput hpa 0;echo "[`(tput setaf 2)` ok ";tput op; tput cnorm; tput rc; echo OK.
#[ ok ]
#OK.

#23 Форматирование текста.
head -n 2 ./замена_коммут_OU.csv
#Port:Name:Status:Vlan:Duplex:Speed:Type:МКУ:Device
#Fa0/1:25/06-0:connected:404:a-full:100:10/100BaseTX:MGS-07:
#Нам нужны адреса(Name).
cat замена_коммут_OU.csv | cut -d ":" -f 2 | sed -E "s/\(.*//g"
#Name
#25/06-0
#...

#24 Вывод grep.
cat ./sw_device.txt
...
#172.19.4.149
#DGS-1100-08
#r3-7/26-6sw2
#d8:fe:e3:40:fc:3a
#......
#172.19.4.150
#Edge-Core FE L2 Switch ES3528M
#nch-ou-MGS29-39_02_2p-acsw1
#70:72:cf:0:e9:fa
...
#Вывести оптические узлы в 27кс, в которых стоят ES3510 или ES3528.
cat sw_device.txt | grep -E 27\(/\|_\) -B 2 -A 1 | grep -E \(ou\|r1.5\) -B 2 -A 1 | grep -E \(ES3510MA\|ES3528M\) -A 2 -B 1
#172.19.1.241
#ES3510MA
#nch-ou-ng27_14-25-acsw1
#70:72:cf:98:e5:85
#--
#172.19.2.206
#ES3510MA
#nch-mgs09-ou27_14-11-acsw1
#70:72:cf:98:d7:15


#25 Sed.
echo /home/dima/d i r | sed 's/.*\//"&"/g'
#"/home/dima/"d i r
echo /home/dima/d i r | sed 's/\(.*\/\)/"\1"/g'
#"/home/dima/"d i r
echo /home/dima/d i r | sed 's/\(.*\/\)\(.*\)/Путь-\1 Директория-\2/g' #Всё что в первыйх скобках запомниться как ссылка 1, и т.д.
#Путь-/home/dima/ Директория-d i r.
#Замена dirname и basename
#\(\)-всё что в скобках это ссылка на \1,\2-вторрая ссылка и.т.д.
#^-начало строки, $-конец строки. .-любой символ кроме пробела, .* - все символы включая пробел.
#\-строгое экранирование.
echo /home/dima/file | sed 's/^.*\/\(..*$\)/\1/g'
#file
echo /home/dima/dir/ | sed 's/^.*\/\(..*$\)/\1/g'
#dir/
echo /home/dima/dir/ | sed 's/\(^.*\/\)..*/\1/g'
#/home/dima/
echo /home/dima/file new work.txt | sed 's/\ /\\&/g' #& - то что совподает с выражением "\ " (пробел), поставим перед ним  экранирование.
#/home/dima/file\ new\ work.txt
#
#Убрать пробелы в начале строк.
ethtool eth0 | grep -E Speed\|Duplex\|Auto-negotiation 
#        Speed: 10Mb/s
#        Duplex: Half
#        Auto-negotiation: on
#Sed-ом с начала строки (^) убераем любое количество предидущих символов т.е. пробелоа (\ *), до первого любого симола кроме пробела (.).
ethtool eth0 | grep -E Speed\|Duplex\|Auto-negotiation | sed 's/^\ *.//g'
#Speed: 10Mb/s
#Duplex: Half
#Auto-negotiation: on


#26 Скрипт в одну строчку, как появиться пинг тогда мы это услышим и цикл прекратиться.
while true ; do ping 172.19.4.254 -A -a  -c 1 && beep && break ;done

#27 Поиск диреторий и фалов в Downloads рекрусивно, после чего сортируем для того чтобы в начале перекодировались имена директорий которые
#дальше от корня, а затем которые лежат ближе к корню. Пример: в начале ./Downloads/dir1/dir2 , а затем ./Downloads/dir1/. Так как иначе переименовав/изменив dir1 не будет существовать
#пути к dir2.После чего перекодируем с cp1251 в utf8.
find ./Downloads/ \( -type f -o -type d \) | sort -r | xargs -i convmv -t utf8 -f cp1251 {} --notest


#28 GREP,SED,AWK,SORT
#Обнуление третего столбца если не равно 0,весь файл выводиться в изменёном виде.
cat ./transl_dict/dict.txt | awk 'BEGIN {FS="#"; OFS="#";} /^.*#/ {if($3 != 0) $3=0;print;}'
#work#работа,работать#0#2015.11.24
#game#игра,играть#0#2015.11.24
#root#корень#0#2015.11.24

cat ./sw_device.txt
...
#......
#172.19.6.94
#DGS-1100-08
#r3-z19/35-1sw1
#d8:fe:e3:40:ff:82
#......
#172.19.6.95
#DGS-1100-08
#r1.5-z19/25-2sw1
#c0:a0:bb:77:b8:b1
#......
#Выведим Dlink DES-2108 и DGS-1100-08 которые стоят в оптических узлах (ou\|r1.5) в строку и выведим столбцы в определённом порядке, и отсартируем по hostname.
...
cat ./sw_device.txt | grep -E DGS\|DES -A 2 -B 1 | grep -E -i ou\|r1.5 -B 2 -A 1 | sed 's/\ /^/g' | tr '\r\n' ' ' | sed 's/--/\n/g' | sed 's/^\ *//g' | awk '{print $3" "$2" "$1" "$4}' | sort -k 1
...
NG^50/15-5^ou DES-2108^V2.00.08 172.19.1.198 00:19:5b:f:99:74
Zyab^18/2a^4p^OU DES-2108^V2.00.08 172.19.0.26 00:19:5b:f:94:f0
NG_7_08_1_ou DES-2108^5.01.B01 172.19.3.182 0f0:7d:68:c2:20:db
ou-19/06-5sw1 DGS-1100-08 172.19.0.83 d8:fe:e3:40:fe:bc
...

#Во втором столбце найти b и вывести строку.
echo -e "1;2;3;4;5\na;b;c;d;e\nA;B;C;D;E" | awk '{FS=";"} $2 == "b" { print $0 }'
a;b;c;d;e

#29 Найти файлы рекрусивно и показать их размер в отсартированном виде по размеру.
find /HDD/ -iname '*.avi' -o -iname '*.mkv' | xargs -i du -sh {} | sort -h -k1
...
#402M    /HDD/backUPrustam/1/Mozgolomy.Sezon6.Seria.53.is.54.2003.XviD.SATRip.avi
#402M    /HDD/backUPrustam/1/Mozgolomy.Sezon6.Seria.54.is.54.2003.XviD.SATRip.avi
#433M    /HDD/VIDEO/House.M.D.s08e01.avi
#695M    /HDD/backUPrustam/Nastoyashiy_muzhchina.avi
...

du -h /home/dima/ | sed 's/\t/ /g' | sort -h -k1
...
#534M /home/dima/.cache
#631M /home/dima/.wine/drive_c/Program Files/MapInfo
#884M /home/dima/.wine/drive_c/Program Files
#1.3G /home/dima/.wine
...


#30 Копирование файлов mp3 с удалённой машины по scp.
scp -P 22 dima@172.16.0.3:"/mnt/2/downloads/Триада\ -\ Тороплюсь\ \(Альбом\ Исток\ 2013\).mp3" /HDD/Mus/
#Также можно указать по список.
scp -P 22 dima@172.16.0.3:"/mnt/2/downloads/2.txt /mnt/2/downloads/1.txt" /HDD/Mus/
#OR
ssh dima@172.16.0.3 -p 22 "ls /mnt/2/downloads/*.mp3;"  | sed -e 's/\ \|(\|)/\\\\&/g' -e 's/\"/\\\\\\&/g' | xargs -i -t scp -P 22 dima@172.16.0.3:{} /HDD/Mus/


#Стянуть таблицу маков с коммутатора.
script ./out.txt
#Скрипт запущен, файл - ./out.txt
telnet 172.19.1.253
...
show macc
...
show mac-address-table vlan 4
...
exit

exit
#exit
#Скрипт выполнен, файл - ./out.txt
cat ./out.txt | grep -i -E "4.*Eth"
...
4 FE-EB-38-18-F1-F8  Eth 1/ 3 Learned
4 FE-F7-62-65-53-49  Eth 1/ 3 Learned
4 FE-F9-3B-7A-50-27  Eth 1/ 3 Learned
4 FE-FB-77-31-AA-89  Eth 1/ 3 Learned
...



#31
#Вывести роутинг 172.19.0.0/21
ip route  | grep -E "172\.19\.[0-7]\..*"
172.19.0.0/21 via 192.168.33.1 dev eth1.113
172.19.0.0/21 dev eth1.10  proto kernel  scope link  src 172.19.1.13
172.19.1.251 dev eth1.10  scope link
172.19.3.4 dev eth1.10  scope link
172.19.4.101 dev eth1.10  scope link
172.19.4.109 dev eth1.10  scope link
172.19.4.254 dev eth1.10  scope link
172.19.5.254 dev eth1.10  scope link
#И для адресов которые ходят не через шлюз, направим через 192.168.33.1
ip route  | grep -E "172\.19\.[0-7]\..*" | grep eth1.10 | grep -v kern | cut -d " " -f 1 | xargs -i ip route chan {} via 192.168.33.1


#32
#Перевести mac в вид.
echo "F8 E9 03 DD C1 D0" | tr '[:upper:]' '[:lower:]' | sed 's/[^^]\([a-f,0-9][a-f,0-9]\)/:\1/g'
#f8:e9:03:dd:c1:d0
echo -e "64-70-PP-AJ-B2-1G\n64-70-02-A5-B2-1B\nCC:D5:39:5B:99:C1" | tr '[:upper:]' '[:lower:]' | sed -E -n "/([a-f,0-9][a-f,0-9][-:]){5}([a-f,0-9][a-f,0-9])/p"
#64-70-02-a5-b2-1b
#cc:d5:39:5b:99:c1
echo -e "Eth 1/10 6C-F0-49-4C-52-4B\nEth 1/10 6C:F0:49:4C:52:4B\nEth 1/10 6CF0.494C.524B\n"  | grep -i --color -E '([[:xdigit:]]{2,4}[-:.]){2,5}[[:xdigit:]]{2,4}'
#Eth 1/10 6C-F0-49-4C-52-4B
#Eth 1/10 6C:F0:49:4C:52:4B
#Eth 1/10 6CF0.494C.524B
echo -e "Eth 1/10 6C-F0-49-4C-52-4B\nEth 1/10 6C:F0:49:4C:52:4B\nEth 1/10 6CF0.494C.524B\n"  | grep -o --color -E '([[:xdigit:]]{2,4}[-:.]){2,5}[[:xdigit:]]{2,4}' | sed 's/[\.:-]//g' | tr '[:upper:]' '[:lower:]' | sed -E "s/([a-f,0-9]{0,2})/:\1/g" |  sed -E 's/(^:| :)//g'
#6c:f0:49:4c:52:4b
#6c:f0:49:4c:52:4b
#6c:f0:49:4c:52:4b




#33
#Посмотрим какиие расширения имеют файлы в директории.
ls /mnt/2/downloads/музычка/ | sed 's/.*\.//g' | sort -u
mp3
txt
#Найдёт (не опускаясь ниже) и удалит файлы у ктороых в расширении нет mp3,Mp3,MP3..
find /mnt/2/downloads/музычка/  -maxdepth 1 -type f ! -iname "*.mp3" -delete

#34
#Проиграть звук(локальный) на удалённой машине.
ssh -p 22 dima@172.16.0.3 'aplay -' < /usr/share/sounds/alsa/Front_Right.wav
#OR
cat /usr/share/sounds/alsa/Front_Right.wav  | ssh -p 22 dima@172.16.0.3 'aplay -'
#Записанный голос с карты 0,0 по ssh перенаправляем на ввод aplay.
arecord -f cd -D plughw:0,0 | ssh -p 33 dima@172.16.0.1 'aplay -'


#35
#Использование символических ссылок для запуска скрипта с разными параметрами.
cat /usr/bin/script_test.sh
##!/bin/bash
#fun () {
#echo "RUN $FUNCNAME"
#}
#
#fun2 () {
#echo "RUN $FUNCNAME"
#}
#
##Если нет первой переменной, тогда var1 = /bin/false которая вернёт код исполнения 1.
#var1=${1:-/bin/false}
#$var1 || `(basename $0)`

ls -la /usr/bin/fun*
#... /usr/bin/fun -> /usr/bin/script_test.sh
#... /usr/bin/fun2 -> /usr/bin/script_test.sh

/usr/bin/script_test.sh fun
#RUN fun
/usr/bin/script_test.sh fun2
#RUN fun2

/usr/bin/fun
#RUN fun
/usr/bin/fun2
#RUN fun2

#36
#Шифруем файл с помощью openssl.
cat ./password.txt 
#OSlinux login:dima password:jsbsdfkjw45
#vk.com login:dibil@mail.ru password:hfkslw3jn
openssl des3 -in ./password.txt -out ./password.cipher 
#enter des-ede3-cbc encryption password:
#Verifying - enter des-ede3-cbc encryption password:
rm ./password.txt
cat ./password.cipher
#sjflkjsldfjlsdjfl #Зашифрованные данные.
openssl des3 -d -in ./password.cipher -out ./password_new.txt
#enter des-ede3-cbc decryption password:
cat  ./password_new.txt
#OSlinux login:dima password:jsbsdfkjw45
#vk.com login:dibil@mail.ru password:hfkslw3jn

#37
#Выясним на каком диске находиться файл/директория.
mount | grep  "`(stat --printf='%m\n' /mnt/2/downloads/123.txt)`\ " | sed -E "s/(^\S*).*/\1/g"
#/dev/sda6

#38
#tcpdump/tshark pipe.
tcpdump -i eth1.10 -w - | ssh dima@172.16.0.2 'cat - > /tmp/10vlan.cap'
#С файла сохранить в другой dump первые 10 пакетов.
tcpdump -r /HDD/tcpdump10vlan.cap | tcpdump -c 10 -w /HDD/tcpdump10vlan_10.cap
#Переписать в файл только первые 50 пакетов в 10 vlan-е.
tcpdump -r /HDD/tcpdump10vlan2.cap -w /HDD/tcpdump10vlan_2.cap vlan 10 -c 50
#Отфильтровать(ftp и ftp-data) пакеты и записать в 1.cap
tshark -r /tmp/client_2.dump -w - -Y "ip.addr == 172.16.0.1 and (tcp.port == 21 or tcp.port == 41867)" | tcpdump -r - -w /tmp/1.cap
#Показать ip source tcp сегментов с ip destination 0.0.0.0 .
tcpdump -r /HDD/tcpdump10vlan_2.cap -nnn dst host 0.0.0.0 and tcp | cut -d " " -f3
#or
tcpdump -r /srv/ftp/dumped/DUMP/tcpdump_eth0_24.cap -U  -nnn | grep '> 0.0.0.0'  | grep Flags | cut -f 3 -d " "
#Вывести ip soruce всех пакетов(cut) и количество повторений(sort и uniq) без указания порта(sed).За место \w можно использовать \S.
tcpdump -r /srv/ftp/dumped/DUMP/tcpdump_eth0_24_2.cap -t -nnn  | cut -d " " -f 2 | sort -h | uniq -c | sed 's/\.\w*$//g' > ./new_bad_ip2.txt

#39
#Подать на ввод diff-у вывод 2-х файлов.
diff <(cat /tmp/1.txt) <(cat /tmp/1.scr)
#or
cat /tmp/1.txt | diff - <(cat /tmp/1.scr)


#40
#Поиск слова shutdown по всем файлам  *.cfg рекрусивно c выводом в каком файле нашёл grep (-H).
find /srv/ftp/ -iname '*.cfg' -type f -exec grep -H shutdown {} \;
#/srv/ftp/ECS3510-52T/default_ECS3510-52T-ELA.cfg: shutdown
#/srv/ftp/ECS3510-52T/default_ECS3510-52T-ZAI.cfg: shutdown

#41
#Наблюдение за ходим выполнения dd и перенаправление по ssh.
du -sb /HDD/data_OS/os_transfer_tech.img
#7803174912      /HDD/data_OS/os_transfer_tech.img
dd if=/HDD/data_OS/os_transfer_tech.img |  pv  -s 7803174912 | ssh root@172.19.12.13 -p 33 'dd of=/dev/sdb'
#root@172.19.12.13's password:
#216MB 0:00:49 [4,95MB/s] [==>                                   ]  2% ETA 0:27:20
#Или
ps -ax 2>/dev/null | grep 'dd if'| grep -v grep
#31465 pts/1    S+     0:03 dd if=/HDD/data_OS/os_transfer_tech.img
kill -USR1 31465
#Увидим отчёт в той консоли где запущен dd.



#42 Подсчёт размер файлов.
du -sh ./
#1,9G    ./
du -abd0 ./ |  awk '{ SUM += $1} END { print SUM/1024/1024/1024 }'
#1.84244

#43 Убираем повторяющиеся пробелы.
echo "a b   c" | tr --squeeze-repeats ' '
#a b c

#44 Видим все правила всех таблиц iptables.
cat /proc/net/ip_tables_names | xargs -t -i iptables -L -t {}

#45 Генерация мак адресса.
head -c 6 /dev/urandom | od --format=x1 --address-radix=n | sed -E -e "s/([0-9a-f]{2}) /\1:/g" -e "s/ //g"


#46 Awk update колонки.
echo -e "192.168.33.3;EdgeCore\n192.168.33.4;Cisco\n192.168.33.5;Huawei" | awk 'BEGIN {FS=";";OFS=";"} $2 == "Cisco" {$3="succes"} {print}'
#192.168.33.3;EdgeCore
#192.168.33.4;Cisco;succes
#192.168.33.5;Huawei
echo -e "192.168.33.3;EdgeCore\n192.168.33.4;Cisco\n192.168.33.5;Huawei" | awk 'BEGIN {FS=";";OFS=";"} $2 == "Cisco" {$3="succes";print}'
#192.168.33.4;Cisco;succes
echo -e "192.168.33.3;EdgeCore\n192.168.33.4;Cisco\n192.168.33.5;Huawei" > /tmp/file.txt
awk  -i inplace 'BEGIN {FS=";";OFS=";"} $2 == "Cisco" {$3="succes"} {print}' /tmp/file.txt 
cat /tmp/file.txt
#192.168.33.3;EdgeCore
#192.168.33.4;Cisco;succes
#192.168.33.5;Huawei

#47 sed Выдернуть значение со строк с разделителем(допустим csv...).
echo -e 'A=a;B=b;C=c;\nA<>1;B<>2;C<>3' | sed -E -n "/=/ s/.*B=([^;]*).*/Result = \1/p"
#Result = b
echo -e 'A=a;B=b;C=c;' | sed -E "s/;*([A|B|C]+)=([^;]*);*/\1++\2;/g"
#A++a;B++b;C++c;

