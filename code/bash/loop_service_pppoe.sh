#!/bin/bash
:
[ ! "$#" = "1" ] && echo  "Not interface." && exit
[ ! "$UID" = "0" ] && echo "Need superuser rights." && exit
! ifconfig ppp0 &> /dev/null && echo "Not ppp0 interface." && exit
:
interf="$1"
pppoe_discovery=`(pppoe-discovery -I "$interf" 2>/dev/null)`
det="0" #Если 1 значит петля была обнаружена.
:
echo "DETECT LOOP..."
OLDIFS=$IFS
IFS=$'\n'
for AC in `(echo "$pppoe_discovery" | grep AC-Ethernet-Address | sed 's/^.*:\ //g')`
 do
  IFS=$OLDIFS
  [ ! "`(echo "$pppoe_discovery" | grep -c "$AC")`" = "1" ] && echo "DETECTED LOOP" && det=1 && break
 done
[ "$det" = "0" ] && echo "NOT DETECTED LOOP"
echo -e "DETECT LOOP.\n"
#Если greep не чего не выдаст т.е. петли нет тогда он выдаст 1.
echo "SERVICES..."
#Понадобилось сделать это в функции для того что бы применить sort -u (убрать повторяющиеся строки) и sed не перекрывая воврощаемое значение greep.
fun ()
{
{ echo "$pppoe_discovery" |  grep AC-Ethernet-Address | sed 's/^.*:\ //g ' | \
  grep -E -v \(00:30:88:20:59:c6\|00:30:88:1b:30:ef\|00:30:88:20:59:c5\) && \
   echo "DETECTED THESE SERVICES.";} || echo "NOT DETECTED THESE SERVICES."
}
fun | sort -u | sed '/^$/d'
echo -e "SERVICES.\n"
