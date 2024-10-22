#!/bin/bash

# Define recording file with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="recording_${TIMESTAMP}.mp4"
PIDFILE="/tmp/wf-recorder.pid"

# Countdown function
countdown() {
    for i in {3..1}
    do
        notify-send "Recording starts in $i"
        sleep 1
    done
    dunstctl close-all
	
}

# Check if wf-recorder is already running
if [ -f "$PIDFILE" ]; then
    # Stop recording
    kill "$(cat $PIDFILE)"
    rm "$PIDFILE"
    notify-send "Recording stopped"
else
    # Start recording
    # geometry=$(slurp)
    countdown
    cd ~
    wf-recorder -f "$FILENAME" &
    echo $! > "$PIDFILE"
#    notify-send "Recording started"
fi
