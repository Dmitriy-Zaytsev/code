#!/bin/bash
mpv \
--no-ytdl \
--v --volume=0 \
--loop=no \
--cache-initial=0 \
--cache=auto \
--cache-default=100000 \
--cache-secs=300 \
--cache-backbuffer=50000 \
--cache-pause=yes \
--demuxer-max-bytes=100000000 \
--demuxer-thread=yes \
--demuxer-readahead-secs=300 \
--force-seekable=yes \
--demuxer-max-bytes=50000000 \
--keep-open=yes \
--playlist=/home/dima/edem_pl.m3u8 \
--playlist-start=2 \
--load-unsafe-playlists \
--load-scripts=yes

#--fs \


