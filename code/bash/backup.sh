#!/bin/bash
##!/bin/bash -x #Для отладки.
funlogger ()
{
level=$1
message=${2:-`</dev/stdin`}
if [ "$level" = "notice" ]
  then
      #Допустим если хотим удалённые файлы отображать в каждую строчку в логах.
      echo "$message" | xargs -i logger "{}"  -t "`(basename $0)` $ipadd" -p local3.$level
  else
      logger ""$message"" -t "`(basename $0)` $ipadd" -p local3.$level
fi
echo $message
return 0
}

funfail ()
{
funlogger info "Stop $0 $ipadd $locald $remoted"
exit 1
}


funlogger info "Start $0 $*"

#[ ! "$UID" = "0" ] && { funlogger err "Operation not permitted."; exit 1;}
[ "$#" = "0" -o "$1" = "-h" ] && echo -e "\
$0 ipaddress localdir remotedir oldbackup oldfile\
" && exit 1
ipadd="$1"
locald="`(echo $2 | sed 's/\/$//g' | sed 's/$/\//g')`$ipadd/"
mkdir $locald -p 2>/dev/null
remoted="`(echo $3 | sed 's/\/$//g')`"
synclocaldir="$locald`(basename $remoted)`"
excluded="$synclocaldir.exclude"
test ! -f $excluded && > $excluded
oldbackup=${4:-30}
oldfile=${5:-30}
tmpfile=/tmp/`basename $0`.tmp

[ -z "$locald" ] && { funlogger err "No variable localdir."; funfail;}
[ -z "$remoted" ] && { funlogger err "No variable remotedir."; funfail;}
[ ! -r  "$excluded" ] && { funlogger err "You can not read $excluded."; funfail;}
ps -ax 2>/dev/null | grep syslog | grep -v grep || { funlogger err "Syslog/Rsyslog not running."; funfail;}

ping $ipadd -c 4 -W 1 &>/dev/null || { funlogger warn "$ipadd not available."; funfail;}
[ ! -w $locald -o ! -d $locald -o ! -x $locald ] && { funlogger err "$locald do not have write/open or not dir."; funfail;}

funlogger info "The beginning of the synchronization."
funlogger info "Exclude file $excluded"
> $tmpfile
#Вывод в лог только количество, и скорость синхронизации.
#{ rsync -rauvh --delete --delete-excluded --exclude-from=$excluded -e ssh backuper@$ipadd:$remoted $locald 2>&1; echo "$?" > $tmpfile;} | grep sent -A 1 | funlogger notice
#u-пропустить если файл новее на приёмнике, уберём так как файл может быть больше по размеру.
{ rsync -ravh --delete --delete-excluded --exclude-from=$excluded -e ssh backuper@$ipadd:$remoted $locald 2>&1; echo "$?" > $tmpfile;} | funlogger notice
ret=`<$tmpfile`
[ ! "$ret" = "0" ] && { funlogger warn "Data not update."; funfail;}
funlogger info "Complete synchronization."

funlogger info "The beginning of the compression."
tar -cvf - $synclocaldir | gzip -9 > $synclocaldir-$(date "+%d-%m-%y_%H:%M").tr.gz
[ ! "$?" = "0" ] && { funlogger warn "Data not compression."; funfail;}
funlogger info "Finished compression."

funlogger info "Start to remove old archives(+$oldbackup day)."
find $locald -maxdepth 1 -type f -ctime +$oldbackup -not -name "*.exclude" -exec /bin/rm -f {} \;
funlogger info "Complete removal of old archives."

funlogger info "Start removing old files/dir(+$oldfile day)."
ret=1
#Проверка для того что бы перенос строки не отображался как #012.
#echo -e "123\nABC" | funlogger info
> $tmpfile
{ ssh backuper@$ipadd "find $remoted/* -depth -atime +$oldfile -a -mtime +$oldfile -exec rm -rfv {} \;"; echo "$?" > $tmpfile;} | funlogger notice
ret=`<$tmpfile`
[ ! "$ret" = "0" ] && funlogger warn "Files were not deleted."
funlogger info "Stop removing old files."

funlogger info "Stop $0 $ipadd $locald $remoted"
exit 0
