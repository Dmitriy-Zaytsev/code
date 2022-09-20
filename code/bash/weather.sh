#!/bin/bash
request="wttr.in/${2:-Набережные_Челны}"
echo -----
request+='?M'
#[ "$1" = "1" ] && request+='?n?1?q'

[[ "$COLUMNS" -lt 125 ]] && request+='?n'
clear
curl -H "Accept-Language: ${LANG}" \--compressed "$request"
