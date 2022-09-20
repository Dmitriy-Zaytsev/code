#!/bin/bash
[[ $(id -u) = "0" ]] || exit 10
MAX_JOBS=50

DIR="/etc
/home
/boot
/root
/opt
/srv
/usr
/var"

MIMETYPE="application/pdf
application/x-shellscript
text/.*
.*opendocument.*
.*word.*
.*excel.*
image/.*
.*/gzip
application/x-tar
application/zip
application/vnd.rar"

ALL_MTYPE=/tmp/all_mtype.txt

BACKUP_DIR="/backup_system/$HOSTNAME"
BACKUP_FILE="/backup_system/"$HOSTNAME".zip.tar"

FTP_SERVER="192.168.33.13"

> $ALL_MTYPE
rm -rf $BACKUP_DIR
rm -rf $BACKUP_FILE
mkdir -p $BACKUP_DIR

OLDIFS="$IFS"
IFS=$'\n'
fun_1 () {
file="$1"
for mimetype in $(echo "$MIMETYPE")
 do
  mtype=`(mimetype -Mb "$file")`
  code=`(file -bi "$file" | cut -d ";" -f2)`
  echo "$file;$mtype;$code" >> $ALL_MTYPE
  echo "$code" | grep -E "(binary|data)" &>/dev/null && continue
  echo "$mtype" | grep "^$mimetype" &>/dev/null || continue
  mkdir -p "$BACKUP_DIR`(dirname "$file")`"
  echo "COPY FILE $file;$mtype;$code"
  cp "$file" "$BACKUP_DIR`(dirname "$file")`"
 done
}

for dir in $(echo "$DIR")
 do
  for file in `(find $dir -type f)`
   do
    fun_1 "$file" &
    while  [ "$(jobs -n | wc -l)" -ge "$MAX_JOBS" ]
     do
      rand=$(($RANDOM % 99))
      echo -e "\nSLEEP random 0.$rand sec\n"
      sleep 0.$rand
     done
   done
 done
IFS=$OLDIFS

echo "TAR DIR $BACKUP_DIR"
tar -czvf $BACKUP_FILE $BACKUP_DIR
wait;wait
sync;sync
echo "PUT FTP $FTP_SERVER $BACKUP_FILE"
cd `(dirname $BACKUP_FILE)`
ftp -n "$FTP_SERVER" <<End-Of-Ses
user anonymous anonymous
binary
cd dumped/
put $(basename $BACKUP_FILE)
bye
End-Of-Ses
cd -

rm -rf $BACKUP_DIR
