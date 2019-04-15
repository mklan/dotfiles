#!/bin/bash

#control sound by defining the next delta increase/decrease and the maximum allowed percantage
#this way you can set volumes higher than 100% but still set a upper limit
#example: ./sound.sh +5 150 

#get active sink
#credits: http://customlinux.blogspot.com/2013/02/pavolumesh-control-active-sink-volume.html
# pacmd list-sinks |awk '/* index:/{print $3}'

# with this you are able to control only when something is playing =/
activeSink=$(pactl list short sinks | grep 'RUNNING\|IDLE' | cut -f1)

delta=$1
max=${2:=100}
# limiting does not work right now
current=$(pamixer --get-volume)

#always unmute in change
pactl set-sink-mute $activeSink 0

if [ $(($current + $delta)) -gt $max ]
then
    exit 1
else
    pactl set-sink-volume $activeSink +$delta% 
fi
