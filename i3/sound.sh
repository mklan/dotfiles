#!/bin/bash

#control sound by defining the next delta increase/decrease and the maximum allowed percantage
#this way you can set volumes higher than 100% but still set a upper limit
#example: ./sound.sh +5 150 

delta=$1
max=${2:=100}

current=$(pamixer --get-volume)
pactl set-sink-mute 0 0

if [ $(($current + $delta)) -gt $max ]
then
    exit 1
else
    pactl set-sink-volume 0 +$delta% 
fi
