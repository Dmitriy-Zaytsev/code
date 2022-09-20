#!/bin/bash
DIR="./"
DEST="/usr/code/"
find $DIR -maxdepth 3 -type f -a \( -iname "*.exp" -o -iname "*.sh" -o -iname "*.py" \) -a -not \( -path "*lib*" -o -path "*share*"  -o -path "*local*" \)  -exec cp -rfv {} $DEST \;
