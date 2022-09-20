#!/bin/bash
#Если нет переменной $1 тогда получим backup.tar.gz
BACKUPFILE=backup
archive=${1:-$BACKUPFILE}.tar.gz
echo $archive
