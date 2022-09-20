#!/bin/bash
#Покажет ветку system.
#snmpwalk -c ghbitktw -v 2c 172.19.3.110 -On
#Скрипт  для сканирования сети 172.19.0.0/21 и 172.19.64-69.0 (запуск без параметров), или -r ./file.txt для считывания построчно ip адресов,
#И определения model,firmware,bootrom...., исходя из этих данных можно запускать скрипты.
[ "$UID" != "0" ] && echo "Нет прав для исполнения NMAP." && exit 0
date=`(date "+%d-%m-%y_%H-%M")`
dir=./NetworkSCAN2
mkdir -p $dir &>/dev/null
#rm $dir/* -r &>/dev/null
echo "--------------------------------------------------------------------"
echo "$0 -s -r /tmp/file.txt - сканирование ip с файла."
echo "$0 -s сканирование ip указанные в скрипте."
echo "$0 -с -r /tmp/file.txt - сканирование ip с файла и запуск скриптов."
echo "$0 -с сканирование ip указанные в скрипте и запуск скриптов."
echo "--------------------------------------------------------------------"

for file_script in ./ES3510MA_add_config.exp ./ES3528M_add_config.exp ./ES3552M_add_config.exp ./ECS3510-28T_add_config.exp
do
[ ! -f "$file_script" ] && echo "Не существует скрипт $file_script." && exit 0
done


#Откл курсор.
tput civis

change_config ()
{
[ "$model" = "ES3510MA" ] && { [ "$firmw" = "1.4.2.4" ] || [ "$firmw" = "1.4.2.6" ];} && { \
./ES3510MA_add_config.exp $ip; [ "$?" = "10" ] && echo "$ip#$model#$firmw#$loader#$bootrom#-->SUCCESS" >> $dir/log_$date.txt ||  echo "$ip#$model#$firmw#$loader#$bootrom#-->FIASCO" >> $dir/log_$date.txt;}

[ "$model" = "Edge-CoreFEL2SwitchES3528M" ] && { [ "$firmw" = "1.4.20.20" ] || [ "$firmw" = "1.4.20.11" ];} && { \
./ES3528M_add_config.exp $ip; [ "$?" = "10" ] && echo "$ip#$model#$firmw#$loader#$bootrom#-->SUCCESS" >> $dir/log_$date.txt ||  echo "$ip#$model#$firmw#$loader#$bootrom#-->FIASCO" >> $dir/log_$date.txt;}

[ "$model" = "Edge-CoreFEL2SwitchES3552M" ] && { [ "$firmw" = "1.4.18.2" ] || [ "$firmw" = "1.4.20.7" ];} && { \
./ES3552M_add_config.exp $ip; [ "$?" = "10" ] && echo "$ip#$model#$firmw#$loader#$bootrom#-->SUCCESS" >> $dir/log_$date.txt ||  echo "$ip#$model#$firmw#$loader#$bootrom#-->FIASCO" >> $dir/log_$date.txt;}


[ "$model" = "ECS3510-28T" ] && [ "$firmw" = "1.5.1.4" ] && { \
./ECS3510-28T_add_config.exp $ip; [ "$?" = "10" ] && echo "$ip#$model#$firmw#$loader#$bootrom#-->SUCCESS" >> $dir/log_$date.txt ||  echo "$ip#$model#$firmw#$loader#$bootrom#-->FIASCO" >> $dir/log_$date.txt;}

return 0
}

fun  ()
{
#Жёлт.
tput setaf 3
#Вывод не спускаясь на следующию строку удаляя предидущее.
tput el
echo -en $ip
#Белый.
tput setaf 7
#Встаём курсором на позицию ноль
tput hpa 0
#Если порт snmp не открыт тогда вернём 1, а там уже сделаем continue в for do done, т.е. следующий ip.
error=0
nmap -sU -n -p 161 $ip | grep open &>/dev/null || error=1
[ "$error" = "1" ] && echo "$ip-->FIASCO" >> $dir/log_$date.txt && return 1
model=`(snmpget -r 2 -t 1 -c ghbitktw -v 2c $ip .1.3.6.1.2.1.1.1.0 2>/dev/null | sed 's/.*://g' | sed -E 's/(\/| )//g')`
firmw=`(snmpget -r 2 -t 1 -c ghbitktw -v 2c $ip .1.3.6.1.2.1.47.1.1.1.1.9.201 2>/dev/null | sed 's/.*STRING: \(.*\)/\1/g')`
loader=`(snmpget -r 2 -t 1 -c ghbitktw -v 2c $ip .1.3.6.1.4.1.259.8.1.11.1.1.3.1.4.1 2>/dev/null | sed 's/.*STRING: \(.*\)/\1/g')`
bootrom=`(snmpget -r 2 -t 1 -c ghbitktw -v 2c $ip .1.3.6.1.4.1.259.8.1.11.1.1.3.1.5.1 2>/dev/null | sed 's/.*STRING: \(.*\)/\1/g')`
hostname=`(snmpget -r 2 -t 1 -c ghbitktw -v 2c $ip .1.3.6.1.2.1.1.5.0 2>/dev/null | sed 's/.*STRING: \(.*\)/\1/g')`
#Если есть в переменной No Such (т.е. нет такого oid, например для Dlink1210), тогда заменить на пусто, и результат попадёт в переменную.
firmw=`(echo $firmw | sed 's/.*No Such.*//g')`
loader=`(echo $loader | sed 's/.*No Such.*//g')`
bootrom=`(echo $bootrom | sed 's/.*No Such.*//g')`
#Присвоить переменной model значения переменной model, если он пустая или только пробел в ней, тогда значение no_model.
firmw=${firmw:-firmware_is_not_received}
hostname=${hostname:-hostname_is_not_received}
loader=${loader:-loader_is_not_received}
bootrom=${bootrom:-bootrom_is_not_received}
#
[ -z "$model" ] && return 1
file="$dir/all_model_$date.txt"
echo "$ip#$hostname#$model#$firmw#$loader#$bootrom" >> $file
[ "$1" = "-c" ] &&  change_config
[ "$1" = "-s" ] && :
return 0
}
#stdout сделам как stderr.

fun_all ()
{
echo "START find model all." >&2
  for oct3 in `(seq 0 7)`
   do
    for oct4 in `(seq 0 255)`
     do
      ip=172.19.$oct3.$oct4
      #tput el - очищаем посл.строку.
      #Вывод с файла последней занесённой строкой.
      fun $1 $2 $3 && { tput el && tail -n 1 $file;} || continue
     done
   done
 for oct3 in `(seq 64 69)`
   do
    for oct4 in `(seq 0 255)`
     do
      fun $1 && tput el && tail -n 1 $file
     done
   done
echo "STOP find model all." >&2;}

fun_file ()
{
echo "START find model of file $2."
while read ip
do
 fun $1 && tput el && tail -n 1 $file
done < $3
echo "STOP find model of file $2."
}



[ "$2" = "-r" ] && [ -f "$3" ] && fun_file $1 $2 $3
[ -z "$2" ] && fun_all $1 $2 $3



#Вкл. курсор.
tput cnorm
echo "Время исполнения $0 $@ $SECONDS сек."
exit 0

#172.19.2.27#RTL8370M#Realtek-Switch#firmware_is_not_received#loader_is_not_received#bootrom_is_not_received
#172.19.2.28#RTL8370M#Realtek-Switch#firmware_is_not_received#loader_is_not_received#bootrom_is_not_received
#172.19.2.29#RTL8370M#Realtek-Switch#firmware_is_not_received#loader_is_not_received#bootrom_is_not_received
#172.19.2.30#nch-mgs51-ou30_6_13-2-acsw1#ES3510MA#1.3.6.5#" 1.0.0.0"#"0.0.0.1"
#172.19.2.31#RTL8370M#Realtek-Switch#firmware_is_not_received#loader_is_not_received#bootrom_is_not_received
#172.19.2.32#RTL8370M#Realtek-Switch#firmware_is_not_received#loader_is_not_received#bootrom_is_not_received
#172.19.2.33

#Первый строчки это вывод с файла куда мы заносили данные, последняя
#жёлтым цветом что мы на данный момент опрашиваем, после чего удаляеться,
#И на неё встаяёт другой ip, но перед этим может попасть на вывод последняя строка с файла,
#вывода с файла не будет только в том случае если функция fun вернёт 1, а это
#возможно если $model будет пуста (fun && tput el && tail -n 1 $file).
