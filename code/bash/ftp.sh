#!/bin/bash
ftp -n 127.0.0.1 <<End-Of-Ses
user anonymous anonymous
binary
cd dumped/
dir
bye
End-Of-Ses
exit 0
