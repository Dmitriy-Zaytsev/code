#/bin/bash
IP_OLD=$1
IP_NEW=$2
login=rabbit
password=rabbit


nmap -p 80 $ip_old -sT -T5 &>/dev/null || { echo "ERROR" "Закрыт порт 80 IP_OLD:$ip_old ." && exit 3;}
fun_post () {
rm -rf /tmp/post_output.txt
curl -L -X POST \
--header "Host: "$ip_old"" \
-A "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" \
--header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
--header "Accept-Language: en-US,en;q=0.5" \
--header "Accept-Encoding: gzip, deflate" \
--header "Referer: http://"$ip_old"/" \
--header "Connection: keep-alive" \
--header "Content-Type: application/x-www-form-urlencoded" \
-d "Login="$login"&Password="$password"&BrowsingPage=index_dlink.htm" \
http://$ip_old -v -o /tmp/post_output.txt

gambit=`(cat /tmp/post_output.txt | grep "script.*Gambit" | sed 's/.*Gambit=\(.*\)" .*/\1/g')`
[ -z "$gambit" ] && { echo "ERROR" "Не удалось получить Gambit(session web) IP_OLD:$ip_old IP_NEW:$ip_new ." && exit 3;}
}


fun_changeip () {
rm -rf /tmp/cahangeip_output.txt
curl -X POST \
--header "Host: "$ip_old"" \
-A "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" \
--header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
--header "Accept-Language: en-US,en;q=0.5" \
--header "Accept-Encoding: gzip, deflate" \
--header "Referer: http://"$ip_old"/iss/System_Setting.htm?Gambit="$gambit"" \
--header "Connection: keep-alive" \
--header "Content-Type: application/x-www-form-urlencoded" \
-d "Gambit="$gambit"&FormName=sys_ip_set&ipaddress="$ip_new"&gateway="$gw_new"&submask="$mask_new"&dhcp=0&preipaddress="$ip_old"&pregateway="$gw_old"&presubmask="$mask_old"&predhcp=0&OptionEnalbe=2" \
--connect-timeout 1 \
--max-time 1 \
http://$ip_old/iss/specific/Sys.js -o /tmp/cahangeip_output.txt -v
}




fun_post
fun_changeip #&
#sleep 0.3 && kill $! -9
#wait
ping -c 3 -W 3 $ip_new &>/dev/null ||  { echo "ERROR" "Не удалось сменить ip IP_OLD:$ip_old IP_NEW:$ip_new ." && exit 4;}
