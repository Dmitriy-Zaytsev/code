#!/bin/bash
win=`(xdotool getactivewindow)`
#xdotool key --clearmodifiers --window $win ctrl+c
#xdotool key --clearmodifiers ctrl+c
xclip -selection primary -o | tee -a /tmp/copy_buffer2.sh.log | xclip -selection clipboard -i
