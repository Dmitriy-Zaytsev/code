#!/bin/bash
AUTOLOGIN=TRUE

ADMIN="ray"

IP="255.255.255.255"
P="3389"
U="user"
Pas="password"
Pro="RDP,VNC"

LOG=/tmp/xfreerdp-gui.log
exec >$LOG 2>&1

PASWD_FILE=/home/$ADMIN/xfreerdp-gui.paswd

dim=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')
wxh1=$(echo $dim | sed -r 's/x.*//')"x"$(echo $dim | sed -r 's/.*x//')
wxh2=$(($(echo $dim | sed -r 's/x.*//')-70))"x"$(($(echo $dim | sed -r 's/.*x//')-70))

while true
  do
  if [ x$AUTOLOGIN = x"TRUE" ]
    then
      AUTOLOGIN_FLAG=":CBE"
      [ -f $PASWD_FILE ] || touch $PASWD_FILE
      cat $PASWD_FILE | sort -n | uniq > /tmp/xfreerdp-gui.tmp
      mv /tmp/xfreerdp-gui.tmp $PASWD_FILE
      IP=$(cat $PASWD_FILE | cut -d "," -f 1 | tr '\n' ',' | sed 's/,$//g')
  fi

  DISPLAY=:0 numlockx status | grep "is on" || DISPLAY=:0 numlockx on

    [ -n "$USER" ] && \
    until xdotool search "xfreerdp-gui" windowactivate key Right Tab 2>/dev/null
      do
        sleep 0.03
      done &
    FORMULARY=$(yad --center --width=500 --height=300 \
    --title "xfreerdp-gui" \
    --text "RDP/VNC


" \
    --text-align=center \
    --form \
    --align=right \
    --focus-field=1 \
    --field="Server""$AUTOLOGIN_FLAG" "$IP" \
    --field="Port" "$P" \
    --field="Username"  "$U" \
    --field="Password":H  "$Pas" \
    --field="Protocol":CB "$Pro" \
    --button="Cancel":1 --button="Connect":0 \
    --fixed \
    --window-icon="gtk-execute" --image="debian-logo" --item-separator="," \
    --splash)

    res=$?
    #[ $res != 0 ] && exit $res

    echo -en "$FORMULARY\nRES:$res\n" | tee $LOG

    SERVER=$(echo $FORMULARY     | awk -F '|' '{ print $1 }')
    PORT=$(echo $FORMULARY       | awk -F '|' '{ print $2 }')
    LOGIN=$(echo $FORMULARY      | awk -F '|' '{ print $3 }')
    PASSWORD=$(echo $FORMULARY   | awk -F '|' '{ print $4 }')
    PROTOCOL=$(echo $FORMULARY   | awk -F '|' '{ print $5 }')

    if [ x$AUTOLOGIN = x"TRUE" ] &&  [ $LOGIN = "$U" ] && [ x$PASSWORD = x"$Pas" ] && [ x$SERVER != x"" ]
      then
        echo "GET PORT:LOGIN:PASSWORD"
        PORT=$(cat $PASWD_FILE | grep "$SERVER" | cut -d "," -f 2)
        LOGIN=$(cat $PASWD_FILE | grep "$SERVER" | cut -d "," -f 3)
        PASSWORD=$(cat $PASWD_FILE | grep "$SERVER" | cut -d "," -f 4)
        PROTOCOL=$(cat $PASWD_FILE | grep "$SERVER" | cut -d "," -f 5)
    fi

    echo $SERVER $PORT $LOGIN $PASSWORD $PROTOCOL

    if [ $PROTOCOL = "RDP" ]
      then
        RES=$(xfreerdp \
        /v:"$SERVER":"$PORT" \
        /cert-tofu /cert-ignore /cert-deny \
        /u:"$LOGIN" /p:"$PASSWORD" \
        /f /gfx:AVC444 /gdi:hw +gfx-progressive \
        /sound \
        +auto-reconnect /auto-reconnect-max-retries:100 \
        +fonts -themes \
        +multitransport /network:auto -compression -encryption \
        +sec-nla -sec-rdp -sec-tls /tls-seclevel:0 2>&1 )
#   Для более слабых машин, при не верной аутентификации будет в windows предлогать ввести по новой.
#   -sec-nla -sec-rdp +sec-tls /tls-seclevel:0 2 >&1 )
        res=$?
    fi

    if [ $PROTOCOL = "VNC" ]
      then
        RES=$(echo $PASSWORD| xtightvncviewer $SERVER:$PORT -autopass -compressleve 0 -quality 9  -nocursorshape  -x11cursor -encodings tight 2>&1)
        res=$?
    fi


    echo -en "$RES\nRES:$res\n" | tee -a $LOG

    ( echo $RES | grep -q -i -E "(ERRCONNECT_LOGON_FAILURE|password check failed)" || [ $res = 127 ] || [ $res = 134 ] ) && \
    yad --center --image="error" --window-icon="error" --title "Authentication failure" \
    --text="<b>Could not authenticate to server\!</b>\n\n<i>Please check your password.</i>" \
    --text-align=center --width=320 --button=gtk-ok --buttons-layout=spread #&& continue

    ( echo $RES | grep -q -i -E "(ERRCONNECT_CONNECT_TRANSPORT_FAILED|Connection refused|No route to host Unable)"  || [ $res = 147 ] ) && \
    yad --center --image="error" --window-icon="error" --title "Connection failure" \
    --text="<b>Could not connect to the server\!</b>\n\n<i>Please check the network connection.</i>" \
    --text-align=center --width=320 --button=gtk-ok --buttons-layout=spread #&& continue

    ( echo $RES | grep -q -i -E "(Terminated)"  || [ $res = 143 ] ) && \
    yad --center --image="error" --window-icon="error" --title "Connection failure" \
    --text="<b>Kill proccess freerdp\!</b>\n\n<i>Please check system.</i>" \
    --text-align=center --width=320 --button=gtk-ok --buttons-layout=spread #&& continue

#set -x
    if ( [ $PROTOCOL = RDP ] &&  [ x$AUTOLOGIN = x"TRUE" ] && [ $res = "11" ] ) || ( [ $PROTOCOL = VNC ] &&  [ x$AUTOLOGIN = x"TRUE" ] &&  [ $res = "0" ] )
      then
        echo "ADD IP:PORT:LOGIN:PASSWORD:PROTOCOL" | tee -a $LOG
        sed -i -E -e "s/$SERVER,$PORT,$LOGIN,$PASSWORD,$PROTOCOL//g" -e "/^$/d" "$PASWD_FILE"
        echo "$SERVER,$PORT,$LOGIN,$PASSWORD,$PROTOCOL" >> $PASWD_FILE
      else
        echo "DELETE IP:PORT:LOGIN:PASSWORD:PROTOCOL" | tee -a $LOG
        sed -i -E -e "s/$SERVER,$PORT,$LOGIN,$PASSWORD,$PROTOCOL//g" -e "/^$/d" "$PASWD_FILE"
    fi
#set +x
    #break
  done
