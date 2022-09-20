#!/bin/bash
my_pid=$$
my_sess="`(ps  -o sess= -p "$my_pid" | sed 's/ *//g')`"
my_ps=`(ps -ax -o sess=,pid=,ppid=,command= | grep -v "$my_sess")`
my_ps_tree=`(ps -axf -o sess=,pid=,ppid=,command=)`
log_ps="/tmp/rclone_sync-ps.log"
log_ps_tree="/tmp/rclone_sync-ps_tree.log"
rclone_list="/etc/rclone/rclone.list"
rclone_conf="/etc/rclone/rclone.conf"


echo -e "\n\n...\tDEBUG\t..."
echo "PID - $my_pid"
echo "LOG - "$log_ps", "$log_ps_tree""
echo "SESS - $my_sess"
echo "$my_ps" > "$log_ps"
echo "$my_ps_tree" > "$log_ps-tree"
echo -e "...\tDEBUG\t...\n\n"

echo "SYNC START"
echo "$my_ps" | grep -v grep | grep -E "sh.*rclone_sync.sh" && { echo "SYNC STOP, rclone_sync run";exit 10 ;}

echo "SYNC PC-->CLOUD"
rclone sync  --copy-links --include-from "$rclone_list" / yandex_disk:sync -v -u --max-delete 0 --skip-links --config  "$rclone_conf"
echo "SYNC CLOUD-->PC"
rclone sync  --copy-links --include-from "$rclone_list" yandex_disk:sync / -v -u --skip-links --config "$rclone_conf"
echo "SYNC END"

#------------------------------------------------
backup_cherrytree="/home/dima/backup_cherrytree"
cherry_file="/home/dima/cherrytree.ctb"
file=`(basename $cherry_file)`
backup_cherry_file=""$backup_cherrytree"/"$file"_`(date +%G-%m-%d_%H)`"
backup_cherrytree_count="32"

echo "BACKUP START"
mkdir -p "$backup_cherrytree"
rm -rf "$backup_cherrytree"/*
cp "$cherry_file" "$backup_cherry_file"
rclone sync "$backup_cherrytree/" yandex_disk:backup/backup_cherrytree -v -u --max-delete 0 --skip-links --config "$rclone_conf"
rm "$backup_cherrytree/*" -rf
echo "BACKUP END"

echo "DELETE_DUPLICAT START"
file=`(rclone lsf --format phs yandex_disk:backup/backup_cherrytree --config "$rclone_conf")`
duble=`(echo "$file" | cut -f2,3 -d ";" | uniq -d)`
for dub in $duble
 do
  echo "$file" | grep "$dub" --color | awk 'FNR>1' | cut -f1 -d ";" | xargs -i rclone delete yandex_disk:backup/backup_cherrytree/{} --config "$rclone_conf" -v
 done
echo "DELETE_DUPLICAT END"

echo "DELETE_BACKUP_OLD START"
file=`(rclone lsf --format pt yandex_disk:backup/backup_cherrytree --config "$rclone_conf")`
backup_new=`(echo "$file" |  sort -t ";" -k2 | tail  -n "$backup_cherrytree_count" | cut -d ";" -f 1)`
for f in `(echo "$file" | cut -d ";" -f 1)`
  do
   echo "$backup_new" | grep  "$f" &>/dev/null || { echo "Delete $f"; rclone delete yandex_disk:backup/backup_cherrytree/"$f" --config "$rclone_conf" -v  ;}
  done
echo "DELETE_BACKUP_OLD END"



echo "DELETE_TRASH START"
token=`(cat "$rclone_conf"  | grep token | sed 's/.*access_token":"\(.*\)","token_type.*/\1/g')`
curl -H 'Authorization: OAuth '$token'' -X "DELETE" https://cloud-api.yandex.net:443/v1/disk/trash/resources?path=
echo "DELETE_TRASH END"

#________________________________________________
