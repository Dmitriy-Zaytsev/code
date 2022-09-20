#!/bin/bash
AUTOLOGIN=TRUE

IP=255.255.255.255
PASWD_FILE=`(pwd)`/xfreerdp-gui.paswd

if [ x$AUTOLOGIN = x"TRUE" ] 
  then 
    AUTOLOGIN_FLAG=":CBE"
    [ -f $PASWD_FILE ] || touch $PASWD_FILE
    IP=$(cat $PASWD_FILE | cut -d "," -f 1 | tr '\n' ',')
fi



yad --center --width=500 --height=300 \
    --title "xfreerdp-gui" \
    --text "TEXT


+" \
    --text-align=center \
    --form \
    --align=right \
    --focus-field=1 \
    --field="Server":$AUTOLOGIN_FLAG $SERVER "$IP" \
    --field="Port"  $PORT "3389" \
    --field="Username" $LOGIN "user" \
    --field="Password":H $PASSWORD "" \
    --button="Cancel":1 --button="Connect":0 \
    --fixed \
    --window-icon="gtk-execute" --image="debian-logo" --item-separator="," \
    --splash  \

