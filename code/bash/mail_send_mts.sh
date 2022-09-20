#!/bin/bash
#Так же у учётки gmail.com должно быть разрешено посылать  почту с других устройств(наш linux/скрипт).
TO_MAIL="$1"
THEME="${2:-THEME}"
MESSAGE="${3:-$(</dev/stdin)}"
#TO_MAIL='Shnufik18.07.87@gmail.com
#dszajtse@mts.ru
#mts.it.mail@gmail.com'

FROM_MAIL='mts.it.mail@gmail.com'
PASSWORD='mtsitmail'
CONF_FILE='/etc/ssmtp/ssmtp.conf'
FILE_MESSAGE='/tmp/message'

echo "mailhub=smtp.gmail.com:587
rewriteDomain=gmail.com
hostname=0405wscre313b2
UseTLS=YES
UseSTARTTLS=YES
AuthUser=$FROM_MAIL
AuthPass=$PASSWORD
FromLineOverride=YES" > $CONF_FILE

echo "To:
From: $FROM_MAIL
Subject: $THEME
Content-Type: text/plain; charset=UTF-8; format=flowed

$MESSAGE" > $FILE_MESSAGE

/usr/sbin/ssmtp $TO_MAIL -C$CONF_FILE -v < $FILE_MESSAGE || { echo "ERROR: Сообщение не отправлено." && exit 1;}

echo "INFO: Сообщение отправлено."
exit 0

