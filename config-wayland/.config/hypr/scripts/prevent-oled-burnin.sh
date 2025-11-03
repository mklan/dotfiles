#!/bin/bash

hyproled -s -a 0:0:2880:45

STATE_FILE="/tmp/hyproled_shift.state"

in=3
out=6

if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
    in=2
    out=4
fi

hyprctl --instance 0 keyword general:gaps_in $in
hyprctl --instance 0 keyword general:gaps_out $out

# #hyprctl keyword monitor DP-3,1920x1080@144,0x0,1