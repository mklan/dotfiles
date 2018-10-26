#!/bin/bash

#get active sink
#credits: http://customlinux.blogspot.com/2013/02/pavolumesh-control-active-sink-volume.html
activeSink=$(pacmd list-sinks |awk '/* index:/{print $3}')
pactl set-sink-mute $activeSink toggle