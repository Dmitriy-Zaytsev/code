#!/bin/bash
packages='curl
jq
sqlite3
'
for pack in $packages
do
dpkg-query -s $pack &>/dev/null || { echo "$pack не установлен."; exit 1;}
done

file_db=~/transl.db
sqlite=`(which sqlite3)`

[[ ! -f "$file_db" ]] && $sqlite $file_db "create table IF NOT EXISTS  dictionary (word TEXT UNIQUE,noun TEXT,verb TEXT,adjective TEXT,adverb TEXT,pronoun TEXT,particle TEXT,preposition TEXT,conjunction TEXT,article TEXT,transcr TEXT);"
#https://tech.yandex.ru/keys/?service=trnsl
api_key_tr="trnsl.1.1.20160519T110411Z.e2cb2985bae9599b.2c61359efac35619519a4a5e3f8d903af2ed5859"
#https://tech.yandex.ru/keys/?service=dict
api_key_dic="dict.1.1.20170323T073000Z.a5bd2f7ba32ba97e.16ea2e53cf8a6d05465b02946e5c8891216d353b"
word="$1"

case $word in #условие проверяется посимвольно.
          *[a-z]*[а-я]* ) lang_of="";; #латиница вместе с кириллицой.
          *[а-я]*[a-z]* ) lang_of="";; #кириллица вместе с латиницей.
          *[!=а-я]* ) lang_of=en;lang_in=ru;Cword_of="$greenU"; Cword_in="$yellow" ;;
          *[!=a-z]* ) lang_of=ru;lang_in=en;Cword_of="$yellowU"; Cword_in="$green" ;;
         esac
[ -z "$lang_of" ] && echo "Не определён язык перевода." && exit 2
lang=""$lang_of"-"$lang_in""

###curl -X POST "https://translate.yandex.net/api/v1.5/tr.json/translate?key="$api_key_tr"&text="$word"&lang="$lang"&format=plain&options=1" 2>/dev/null |  jq  .text[]
translate=`(curl -X POST "https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key="$api_key_dic"&lang="$lang"&text="$word"" 2>/dev/null")`
echo "$translate" > /tmp/1.txt
#echo "$translate" | jq -c -M '.def[0]|{text, ts}'
#echo "$translate" | jq -c -M '.def[0,1,2].tr[0]|{pos,text}'
#echo "$translate" | jq -c -M '.def[0].tr[0].mean[0].text'
$sqlite $file_db "INSERT INTO dictionary(`(echo "$translate" | jq -r -c -M '.def[0,1,2].tr[0].pos' | tr '\n' ',')`word) VALUES (`(echo "$translate" | jq -c -M '.def[0,1,2].tr[0].text' | tr '\n' ',')``(echo "$translate" | jq -c -M '.def[0].text')`);"
