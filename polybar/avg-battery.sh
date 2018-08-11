#!/bin/sh

path_ac="/sys/class/power_supply/AC"
path_battery_0="/sys/class/power_supply/BAT0"
path_battery_1="/sys/class/power_supply/BAT1"

ac=0
battery_level_0=0
battery_level_1=0
battery_max_0=0
battery_max_1=0

if [ -f "$path_ac/online" ]; then
    ac=$(cat "$path_ac/online")
fi

if [ -f "$path_battery_0/energy_now" ]; then
    battery_level_0=$(cat "$path_battery_0/energy_now")
fi

if [ -f "$path_battery_0/energy_full" ]; then
    battery_max_0=$(cat "$path_battery_0/energy_full")
fi

if [ -f "$path_battery_1/energy_now" ]; then
    battery_level_1=$(cat "$path_battery_1/energy_now")
fi

if [ -f "$path_battery_1/energy_full" ]; then
    battery_max_1=$(cat "$path_battery_1/energy_full")
fi

battery_level=$(("$battery_level_0 + $battery_level_1"))
battery_max=$(("$battery_max_0 + $battery_max_1"))

battery_percent=$(("$battery_level * 100"))
battery_percent=$(("$battery_percent / $battery_max"))

if [ "$ac" -eq 1 ]; then
    icon=""

    if [ "$battery_percent" -gt 97 ]; then
        echo "$icon"
    else
        echo "$icon $battery_percent %"
    fi
else
    if [ "$battery_percent" -gt 85 ]; then
        icon=""
    elif [ "$battery_percent" -gt 60 ]; then
        icon=""
    elif [ "$battery_percent" -gt 35 ]; then
        icon=""
    elif [ "$battery_percent" -gt 10 ]; then
        icon=""
    else
        icon=""
    fi

    echo " $battery_percent%"
fi
