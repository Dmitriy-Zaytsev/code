#!/bin/bash
#Скрипт для передачи по ftp файла cars.commercial.trucks.csv/xls(конвертируеться), а так же картинок (приложение к таблице) в rar архиве. И файла end.txt
file_xls="/home/backuper/publicdocs/irr_ru/cars.commercial.trucks.xls"
file_csv="/home/backuper/publicdocs/irr_ru/cars.commercial.trucks.csv"
pictures="/home/backuper/publicdocs/irr_ru/pictures"
pictures_rar="/home/backuper/publicdocs/irr_ru/pictures.rar"
flag_file="/home/backuper/publicdocs/irr_ru/end.txt"
date_current="`(date "+%Y-%m-%d")`"
date_file="`(stat $file_xls | sed -n '6p' | cut -f 2 -d " ")`"
#success_file="/home/backuper/`(basename $0)`_`(date "+%Y-%m-%d".lock)`"
#find /home/backuper/ -iname '*irr*lock' -a ! -ipath "$success_file" -delete
#test -f $success_file || echo 0 > $success_file
#success="`(cat $success_file)`"
size_pic_file="/home/backuper/`(basename $0)`_size_pic.txt"
test -f $size_pic_file || echo 0 > $size_pic_file
size_pic_curr="`(du -b /home/backuper/publicdocs/irr_ru/pictures/ | cut -f 1)`"
size_pic_old="`(cat $size_pic_file)`"
#[ "$success" = "1" ] && echo "File already transferred." && exit 0

fun_transfer ()
{
echo "Info:Start transfer."
smbstatus -L  | grep `(basename $file_xls)` &>/dev/null && echo "Error:File Open." && return 1
#libreoffice --headless --convert-to csv "$file_xls" --outdir `(dirname $file_xls)`|| return 1
echo "Info:Start convert."
#Разделитель ; так как MS Office его понимает.
ssconvert --import-encoding=Gnumeric_Excel:excel --export-type=Gnumeric_stf:stf_assistant -O 'separator=;' $file_xls $file_csv &>/dev/null
cp $file_csv /tmp/`(basename $file_csv)`
echo  "Info:Start utf-8 in cp1251."
iconv -f UTF-8 -t CP1251 /tmp/`(basename $file_csv)` -o $file_csv &>/dev/null
rm /tmp/`(basename $file_csv)`
cd `(dirname $file_xls)`
echo  "Info:FTP put $file_csv."
lftp -u power_page_191,ahrienae uploads.irr.ru -e "put $file_csv;exit" &>/dev/null || return 1
if  [ ! "$size_pic_old" = "$size_pic_curr" ]
  then
    echo "Info:Start transfer picture."
    echo $size_pic_curr > $size_pic_file
    echo " echo $size_pic_curr > $size_pic_file"
    echo  "Info:RAR $pictures."
    rar a $pictures_rar $pictures &>/dev/null || return 1
    echo  "Info:FTP put $pictures_rar."
    lftp -u power_page_191,ahrienae uploads.irr.ru -e "put $pictures_rar; exit" &>/dev/null || return 1
    rm $pictures_rar
fi
echo  "Info:FTP put $flag_file."
lftp -u power_page_191,ahrienae uploads.irr.ru -e "put $flag_file;exit" &>/dev/null || return 1
cd $HOME
echo "End $(basename $0)"
return 0
}


#[ "$date_current" = "$date_file" ] && [ "$success" = "0" ] && fun_transfer && echo 1 > $success_file
success=0

while  [ "$success" = "0" ]
  do
    fun_transfer && success=1
    sleep 10
  done
