#!/bin/bash

#get active sink
#credits: http://customlinux.blogspot.com/2013/02/pavolumesh-control-active-sink-volume.html
activeSink=$(pactl list short sinks | grep RUNNING | cut -f1)
pactl set-sink-mute $activeSink toggle