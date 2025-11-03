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
        slept=0
        while [ $slept -lt 120 ]; do
            sleep 5
            slept=$((slept + 5))
            charging=$(upower -i "$(upower -e | grep BAT)" | grep -E "state" | awk '{print $2}')
            if [ "$charging" == "charging" ]; then
                notify-send "Charger plugged in. Suspend aborted."
                break
            fi
        done
        if [ "$charging" != "charging" ]; then
            systemctl suspend
        fi
    elif [ "$battery" -le "20" ]; then
        notify-send "Low battery: ${battery}%"
        sleep 240
    else
        sleep 120
    fi
done

