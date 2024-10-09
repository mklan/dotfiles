#!/bin/bash

while true; do
    battery=$(upower -i "$(upower -e | grep BAT)" | grep -E "percentage" | awk '{print $2}' | tr -d '%')
    charging=$(upower -i "$(upower -e | grep BAT)" | grep -E "state" | awk '{print $2}')

    if [ "$charging" == "charging" ]; then
        sleep 300
        continue
    fi

    if [ "$battery" -le "7" ]; then
        notify-send "Critical battery: ${battery}%. Will shutdown in 2 Min"
        sleep 120
        systemctl suspend
    elif [ "$battery" -le "20" ]; then
        notify-send "Low battery: ${battery}%"
        sleep 240
    else
        sleep 120
    fi
done

