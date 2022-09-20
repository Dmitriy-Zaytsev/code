#!/usr/bin/bash
User="$1"
LoginAd='radius'
PassAd='Nh@aabrN3'
GroupAd='rgread|rgwrite|rgfull'
echo $@ > /tmp/auth.tmp

UserGrAd=`(net ads user info "$User" -U $LoginAd'%'$PassAd | grep -E "($GroupAd)" | tail -n 1 2>/dev/null)`

[ -z "$UserGrAd" ] && { exit 10 ;}

case "$UserGrAd" in
        rgread) echo 'Mikrotik-Group="read"'; exit 0 ;;
        rgwrite) echo 'Mikrotik-Group="write"'; exit 0 ;;
        rgfull) echo 'Mikrotik-Group="full"'; exit 0 ;;
        *) exit 20;;
esac
