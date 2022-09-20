#!/bin/bash
#Удаление кэш-а загруженых пакетов, т.е пакеты в начале в /var/cache/apt/archives/ скачиваются а после чего удаляются.
aptitude clean || exit 1
aptitude update || exit 1
#Скрипт запуститься через cron а всё что выйдет в stderr отправиться на почту(если почта настроена).
echo "MESSAGE STDOUT"
echo "CRON:$0 Success." 1>&2

