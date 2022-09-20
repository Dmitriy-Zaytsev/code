#!/bin/bash
for ip in `(cat ./ip_model_cut.txt | cut -f 1 -d ";")`
 do
  sed  "/^$ip;/d" ./ip_model_cut_backup.txt -i
 done

for ip in `(cat ./ip_download.txt | cut -f 1 -d ";")`
 do
  sed  "/^$ip;/d" ./ip_model_cut_backup.txt -i
 done

