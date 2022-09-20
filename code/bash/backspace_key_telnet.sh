#!/bin/bash
#Скрипт для правильного передачи символов(для dlink3200) по телнет при нажатии backspace.
##cat /etc/bash.bashrc | grep 'alias telnet'
##alias telnet='/usr/bin/telnet.sh'
ip=$1
community=ghbitktw
model=`(snmpget -r 1 -t 2 -c $community -v 2c $ip .1.3.6.1.2.1.1.1.0  -Oqv 2>/dev/null | sed -E 's/(\/| |")//g')`
echo "SCIPT $0"
echo "$model"
if [[ "x$model" =~ "xDES-3200-10C1FastEthernetSwitch" ]]
 then
/usr/bin/expect -c "\
spawn telnet $ip
interact {
\177      {send \010}
\033\[3~  {send \177}
}
"
#\telnet для того что бы не сработал alias, хоть в скриптах они не работают так как
#alias-ы читаются при логине(bashrc,bash_profile,bash_aliases...),а не при новом запуске экземпляра bash.
 else
  \telnet $ip
fi
###!/usr/bin/expect
##interact {
## \177        {send "\010"}
## "\033\[3~"  {send "\177"}
##}
