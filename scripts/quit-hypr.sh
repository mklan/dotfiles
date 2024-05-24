#!/usr/bin/env bash

if pgrep -x Hyprland >/dev/null; then
    hyprctl dispatch exit 0
    sleep 2
    if pgrep -x Hyprland >/dev/null; then
        killall -9 Hyprland
    fi
fi