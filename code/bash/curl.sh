#/bin/bash
IP_OLD=$1
IP_NEW=$2
ip=10.218.58.73
login=rabbit
password=rabbit

ipcalc="`(ipcalc -n "$IP_OLD")`"
export gw_old=`(echo "$ipcalc" | grep HostMin | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
export net_old=`(echo "$ipcalc" | grep Network | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
export ip_old="${IP_OLD%%/*}"
export mask_old=`(echo "$ipcalc" | grep Netmask | sed "s/Netmask: *\(.*\) =.*/\1/g")`
export hosts_old=`(echo "$ipcalc" | grep Hosts | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
((hosts_old=$hosts_old+2))

ipcalc="`(ipcalc -n "$IP_NEW")`"
export gw_new=`(echo "$ipcalc" | grep HostMin | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
export net_new=`(echo "$ipcalc" | grep Network | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
export ip_new="${IP_NEW%%/*}"
export mask_new=`(echo "$ipcalc" | grep Netmask | sed "s/Netmask: *\(.*\) =.*/\1/g")`
export hosts_new=`(echo "$ipcalc" | grep Hosts | sed -E "s/ {1,99}/ /g" | cut -f "2" -d " ")`
((hosts_new=$hosts_new+2))


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
ping -c 2 -W 2 $ip_new &>/dev/null ||  { echo "ERROR" "Не удалось сменить ip IP_OLD:$ip_old IP_NEW:$ip_new ." && exit 4;}
