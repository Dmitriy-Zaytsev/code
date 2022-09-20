#!/bin/bash
#Скрипт сырой.
#Нужные пакеты.
packages_inst='
lame
sox
'
for package in $packages_inst
do
 ! dpkg-query -s "$package" &>/dev/null &&  { echo "Не установлен $package."; exit 2;}
done

echo "Запись пошла..."
arecord -d 3 -q -f cd -r 16000 /tmp/voice.wav
echo "."

echo "Конвертирование записи..."
sox /tmp/voice.wav /tmp/voice.flac gain -n -5 silence 1 5 2%
rm /tmp/voice.wav
echo "."

echo "Get запрос http..."
http_out=`(wget -q -U "Mozilla/5.0" --post-file /tmp/voice.flac --header="Content-Type: audio/x-flac; rate=16000" -O - "http://www.google.com/speech-api/v1/recognize?lang=ru-RU&client=chromium")`
rm /tmp/voice.flac
echo "."
echo $http_out
