#!/bin/bash
proto=${1:-tcp}
ip=${2:-127.0.0.1}
port=${3:-22}

echo -e ".....\nCheck $ip:$port $proto.\n....."
(> /dev/$proto/$ip/$port) &>/dev/null && echo "Open $ip:$host $proto." \
|| echo "Close $ip:$port $proto."
