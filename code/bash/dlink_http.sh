#/bin/bash
#Смена ip и менеджмент vlan-а через http.
export ip_old=172.19.7.254
export ip_new=10.218.56.5
export gw_old=172.19.7.1
export gw_new=10.218.56.1
export mask_old=255.255.255.0
export mask_new=255.255.255.192
export vlanname="mgmt_ou"
export login=rabbit
export password=rabbit


#Получение PUBLIC KEY.
nmap -sT -p 80 $ip_old -n | grep -i open &>/dev/null || { echo "error not open port 80";exit 2;}
rm ./Encrypt.js* -rf
EN_DATA=`(wget http://$ip_old/Encrypt.js -O - 2>/dev/null | sed "s/.*= '\(.*\)'.*/\1/g")`
echo -e "-----BEGIN PUBLIC KEY----- $EN_DATA -----END PUBLIC KEY-----" > /tmp/dlink_key.pub
#Получение криптованного(публичным ключём) логина и пароля,через скрипт dlink_http.js.
ecryp=`(phantomjs ./dlink_http.js $login $password "$(cat ./dlink_key.pub)" $ip_old)`
ecryp_login=`(echo "$ecryp" | sed -n '1p')`
ecryp_password=`(echo "$ecryp" | sed -n '2p')`
#echo -e "1:$ecryp_login\n2:$ecryp_password"
[[ -z "$ecryp_login" || -z "$ecryp_password" ]] && { echo "error encrypt login and password";exit 2;}

echo "$ecryp_login" > /tmp/ecryp_login.txt
echo "$ecryp_password" > /tmp/ecryp_password.txt


#Получение gambit(что то на подобие cookie).
rm /tmp/gambit.txt -rf
curl -X POST \
--header "Host: "$ip_old"" \
-A "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" \
--header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
--header "Accept-Language: en-US,en;q=0.5" \
--header "Accept-Encoding: gzip, deflate" \
--header "Referer: http://"$ip_old"/" \
--header "Connection: keep-alive" \
--header "Content-Type: application/x-www-form-urlencoded" \
--data-urlencode pelican_ecryp="$ecryp_login" \
--data-urlencode pinkpanther_ecryp="$ecryp_password" \
--data-urlencode BrowsingPage=index_redirect.htm \
--data-urlencode lang="" \
--data-urlencode Auth_code="" \
--connect-timeout 1 \
--max-time 1 \
http://$ip_old -o /tmp/gambit.txt -v 2>/dev/null


gambit=`(cat /tmp/gambit.txt | sed 's/name/\n&/g' | grep Gambit | sed 's/.*value="\(.*\)"><.*/\1/g')`

#Меняем ip вместе с management vlan(3 - mgmt_ou).
rm /tmp/chang_ip.txt -rf
curl -X POST \
--header "Host: "$ip_old"" \
-A "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" \
--header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
--header "Accept-Language: en-US,en;q=0.5" \
--header "Accept-Encoding: gzip, deflate" \
--header "Referer: http://"$ip_old"/iss/System_Setting.htm?Gambit="$gambit"" \
--header "Connection: keep-alive" \
--header "Content-Type: application/x-www-form-urlencoded" \
-d "Gambit="$gambit"&FormName=sys_ip_set&ipaddress="$ip_new"&gateway="$gw_new"&submask="$mask_new"&dhcp=0&interfacename=&preipaddress="$ip_old"&pregateway="$gw_old"&presubmask="$mask_old"&predhcp=0&OptionEnalbe=2&vlanname="$vlanname"" \
--connect-timeout 1 \
--max-time 1 \
http://$ip_old/iss/specific/Sys_ip_set.js -o /tmp/chang_ip.txt -v 2>/dev/null
