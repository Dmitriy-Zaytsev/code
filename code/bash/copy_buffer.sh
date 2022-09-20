#!/bin/bash
win=`(xdotool getactivewindow)`
#xdotool key --clearmodifiers --window $win ctrl+c
#xdotool key --clearmodifiers ctrl+c
xclip -selection clipboard -o | tee -a /tmp/copy_buffer.sh.log | xclip -selection primary -i
