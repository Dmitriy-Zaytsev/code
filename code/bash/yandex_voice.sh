#!/bin/bash
text=$1
text='Здраствуйте ............................вас приветствует такси Матрёшка..........для соединения с+ оператором нажмите 1'
wget "https://tts.voicetech.yandex.net/generate?\
text=$text\
&format=mp3\
&lang=ru-RU\
&speed=1.0\
&speaker=oksana\
&emotion=good\
&quality=hi\
&key=0827f91b-9c92-4ba2-9407-7640f2453e8c\
" -O - | mpg123 -
