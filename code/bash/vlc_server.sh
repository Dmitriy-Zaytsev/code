#!/bin/bash
file=${1:-TinyToon_1.mp4}

##udp
#cvlc $file --sout="#transcode{vcodec=h264,acodec=mpga,ab=128,channels=2,samplerate=44100,scodec=none}:udp{dst=239.1.1.1:5004}}" --no-sout-all --sout-keep --loop --ttl=50 --mtu=1000

#cvlc $file --sout="#transcode{vcodec=mpeg,acodec=mpga,ab=64,channels=2,samplerate=32000,scodec=none,fps=15}:udp{mux=ts,dst=239.1.1.1:5004}" --no-sout-all --sout-keep --loop --ttl=50 --mtu=1316 --no-audio

#cvlc $file --sout="#transcode{vcodec=mp4v,scale=Auto,acodec=mp4a,ab=64,channels=1,samplerate=8000,scode=none}:udp{mux=ts,dst=239.1.1.1:5004}" --no-sout-all --sout-keep --loop --ttl=50 --mtu=1316 --no-audio


##udp/rtp##
cvlc $file --sout="#transcode{mp4v,scale=Auto,acodec=mp4a,ab=64,channels=1,samplerate=8000,scode=none,fps=30}:rtp{mux=ts,dst=239.1.1.1,port=5004,name=Video,ttl=50}" --no-sout-all --sout-keep --loop --mtu=1316
