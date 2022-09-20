#!/bin/bash
#Сканирование хоста который не отвечает на эхо-запросы.
key="-nsT"
if [ "$UID" != "0" ]
  then echo "Operation not permitted";exit
fi
echo "nmap с ключами $key."
echo "Для прекращения нажмите ENTER."
read -p "Введите сканируемый ip адрес " ip
while true
do
dat=`(nmap $key $ip)`
if  echo $dat | grep report > /dev/null
then echo -e "\n----$ip доступен.----\n";kill $$; break
fi
done & #В фоне.
:
i=1
##while [ ! -z "$i" ]
while [ "$i" = "1" ]
do
read i
done
kill $! 2> /dev/null #PID последнего процесса запущенного в фоне.

