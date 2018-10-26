#!/bin/sh

# media control
# https://github.com/x70b1/polybar-scripts/blob/master/polybar-scripts/player-mpris-simple/player-mpris-simple.sh

player_status=$(playerctl status 2> /dev/null)

if [ "$player_status" = "Playing" ]; then
    echo "     $(playerctl metadata artist) - $(playerctl metadata title)"
elif [ "$player_status" = "Paused" ]; then
    echo "     $(playerctl metadata artist) - $(playerctl metadata title)"
else
    echo ""
fi
