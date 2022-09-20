#!/bin/bash
dir_file=${1:-$PWD} #Если первого арг. пуст тогда примет значение текущей директории.
list=; #Файлы mp3 с директори.
path_mp3=; #Путь+Файл.
path=; #Путь.
mp3=; #Файл.
tmp_mp3=; #Промежуточный результат.
cut_mp3=; #Конечный результат.
key=; #Выбор действия.
start_time=; #Последнее время с mpg123.
STsec=; #Переведённое $start_time время в сек.мсек.
end_time=; #Последнее время с mpg123.
ETsec=; #Переведённое $end_time время в сек.мсек.
OLDIFS=; #Старый разделитель.
:
:
packages_inst='mpg123
sox
ffmpeg
libsox-fmt-mp3'

for package in $packages_inst
do
 ! dpkg-query -s "$package" &>/dev/null &&  { echo "Не установлен $package."; exit 2;}
done
:
func () {
 clear #Можем reset но тогда очиститься весь вывод, а не только видимой части терминала.
 #path=`(echo $path_mp3 | sed 's/\(^.*\/\)\(.*$\)/\1/g')`
 #mp3=`(echo $path_mp3 | sed 's/\(^.*\/\)\(.*$\)/\2/g')`
#OR
 path="`(dirname \"$path_mp3\")`/" #Экранированы ", для того что бы передать их dirname/basename.
 mp3="`(basename \"$path_mp3\")`"
 :
 tmp_mp3=`(echo "$mp3" | sed 's/\(.*\)\(.mp3\)/\1(tmp)\2/g')`
 cut_mp3=`(echo "$mp3" | sed 's/\(.*\)\(.mp3\)/\1(cut)\2/g')`
 :
 echo ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
 echo -e "\e[2;36m$mp3\e[0m \e[1;35mSTART TIME\e[0m"
 func_echo () { #Описываем функцию, вывод справки по mpg123.
 echo -en "\e[1;33m"s"\e[0m/\e[1;33m"\" \""\e[0m -- stop/play. "
 echo -e  "\e[1;33m"q"\e[0m -- quit/apply. "
 echo -en "\e[1;33m"\<"\e[0m/\e[1;33m"\>"\e[0m -- slow rewind/forward. "
 echo -e "\e[1;33m"\;"\e[0m/\e[1;33m"\:"\e[0m -- fast rewind/forward. "
 echo -e "\e[1;33m"-"\e[0m/\e[1;33m"+"\e[0m -- volume down/up. "
 echo ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
 }
 func_echo #Запуск функц. вывод справки по mpg123.
 mpg123 -C -v "$path$mp3" 2>&1 | tee /tmp/`basename $0`.tmp #Проиграем с выводом stdout, а также stderr ( 2>&1 ) на ввод tee, он в свою очередь выведет в stdout и файл.
 start_time=`(basename $0 | xargs -i cat /tmp/{}.tmp | grep Frame | sed 's/.*Time: \(.*\) \[.*/\1/g')` #Вырежем время на котором мы остановились.
 STsec=$(echo $(((`date -d 00:"$start_time"0 +%s%N` - `date -d 00:00:00.000 +%s%N`)/1000000)) | sed 's/...$/.&/g' | sed 's/^\./0./g') # Переведём в сек.мсек поставим, точку от конца строки через три символа, и если начинаеться  с точки тогда заменим на точку и 0.
 ffmpeg -v quiet -i "$path$mp3" -ss "$STsec" -acodec libmp3lame -ab 320k "$path$tmp_mp3" #Срежем начало записи.
 clear
 :
 echo ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
 echo -e "\e[2;36m$mp3\e[0m \e[1;35mSTOP TIME\e[0m"
 func_echo #Запуск функц. вывод справки по mpg123.
 mpg123 -C -v "$path$tmp_mp3" 2>&1 | tee /tmp/`basename $0`.tmp #Проиграем срезанный кусок.
 end_time=`(basename $0 | xargs -i cat /tmp/{}.tmp | grep Frame | sed 's/.*Time: \(.*\) \[.*/\1/g')`
 ETsec=$(echo $(((`date -d 00:"$end_time"0 +%s%N` - `date -d 00:00:00.000 +%s%N`)/1000000)) | sed 's/...$/.&/g' | sed 's/^\./0./g')
 ffmpeg -v quiet -i "$path$tmp_mp3" -ss 00:00.00 -t "$ETsec" -acodec libmp3lame -ab 320k "$path$cut_mp3" #Срежем с начала до времени где мы остановились.
 rm "$path$tmp_mp3" #Удалим временный кусок записи.
 sox "$path$cut_mp3" -C 320 "$path$tmp_mp3" fade t 0.8 0 #fade in/out за 0,8 сек.
 mv -f "$path$tmp_mp3" "$path$cut_mp3" #Временный кусок переместиться как готовый.
 clear
 :
 echo ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
 echo -e "\e[2;36m$mp3\e[0m \e[1;35mDEMONSTRATION\e[0m"
 func_echo #Запуск функц. вывод справки по mpg123.
 mpg123 -C -v "$path$cut_mp3" 2>&1 #Демонстрация того что получили.
 clear
 :
 key=y #key по умолчанию, если мы нажмём не y,n или r.
 read -s -n 1 -p "Оставить результат $path$cut_mp3 Y/n/r(Yes/no/repeat)" key
 echo -e "\n$key" #Вывести результат выбора на новой строке.
 case $key in
 "y" ) echo -e "\e[1;34mREADY\e[0m $path$cut_mp3";;
 "n" ) rm "$path$cut_mp3" && echo -e "\e[1;31mCANCEL\e[0m $path$cut_mp3";;
 "r" ) echo -e "\e[1;33mREPEAT\e[0m $path$cut_mp3"; func ;; #Запустим заного эту же функцию.
   * ) echo "Выбран вариант по умолчанию Yes."; echo -e "\e[1;34mREADY\e[0m $path$cut_mp3";;
 esac
 sleep 1 #Для того что бы за сеунду увидеть результат выбора, перед clear.
 :
 #Понадобилось  если мы резали трек в конце выбора START и STOP TIME.
 #if [ "$LTsec" \< "0" ] || [ "$LTsec" = "0" ]
 #  then echo -e "\e[2;31mВремя конца записи < времени начала записи.\e[0m"
 #       func
 #fi
}
:
:

if test -f "$dir_file" && test -r "$dir_file" && test -w `dirname "$dir_file"`/ ; then path_mp3="$dir_file"; func; exit; fi #Если арумент файл тогда запустим функцию func (обход цикла).
dir_file=`(echo "$dir_file" | sed -e 's/\/$//g' -e 's/$/\//g' )` #Если это не файл то скорей всего директория, удалим если есть / в конце строки и добавим /.
if ! test -d "$dir_file"; then echo "Указана не верная директория."; exit; fi
if ! test -r "$dir_file"; then echo "Директория не доступна на чтение."; exit; fi
if ! test -w "$dir_file"; then echo "Директория не доступна на запись."; exit; fi
:
list=`(file -i $dir_file* | grep "audio/mpeg; charset=binary" | cut -d ":" -f 1)` #Все файлы в директории(не рекурсивно) с mime "audio/mpeg; charset=binary".
OLDIFS=$IFS #Сохраним старый разделитель.
IFS=$'\n' #Для того что бы for считал перевод строки за следующую передачу переменной path_mp3, а не пробел.
for path_mp3 in $list
do
 clear
 IFS=$OLDIFS #Вернём всё на свои места.
 key=n
 read -s -n 1 -p "Резать аудиозапись `(basename \"$path_mp3\")` y/N(yes/No)" key
 if [ "$key" = "y" ]
    then
        func #Запуск функции описанной выше.
    else
        continue #Поднимаемся на верх, новое значение переменной path_mp3 от for.
 fi
done
