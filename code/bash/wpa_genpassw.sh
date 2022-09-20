#!/bin/bash
[ "$#"  != "2" ] && echo "Введите ssid и ключь в открытом виде." && exit
funWPA_GENPASSW ()
{
wpa_passphrase $1 <<EOF
$2
EOF
}
hexpass=$(funWPA_GENPASSW $1 $2 | sed -E -n 's/[^#]psk=(.*)/\1/p')
echo $hexpass
