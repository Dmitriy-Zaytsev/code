#!/bin/bash
#Пример того как можно заменить i3status скриптом и перевести на язык понимающий i3bar,
#пример был получен с вывода i3status в консоль.
i=0
echo  '{"version":1}'
echo '['
while test $i -lt 5
do
echo '[{"color":"#550055","full_text":"status: RUN' $i' "}],'
sleep 1
i=$((i+1))
done
echo -e '[{"color":"#550055","full_text":"status: END "}],'
echo ]
#sleep 5

#######
#nano  ./.i3/config
#bar {
#      #status_command i3status
#       status_command  /usr/bin/i3status.sh
#}
