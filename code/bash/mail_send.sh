#!/bin/bash
#SSMTP настроен на аворизацию shnufik18.07.87@gmail.com, также есть ящик на sms.ru.
MESSAGE=$1
FROM_MAIL="shnufik18.07.87@gmail.com"
TO_MAIL="7c60ea6c-8965-edf4-75cc-23261139c637+79196218476@sms.ru"
echo "$MESSAGE" | mail -v -s THEME -a "From:$FROM_MAIL" -a "Content-Type:text/plain; charset=UTF-8; format=flowed" $TO_MAIL || { echo "ERROR: Сообщение не отправлено." && exit 1;}
echo "INFO: Сообщение отправлено."
exit 0

