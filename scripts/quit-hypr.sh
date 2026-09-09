#!/usr/bin/env bash

if pgrep -x Hyprland >/dev/null; then
    # 0.56 Lua config: dispatchers are invoked as Lua expressions
    hyprctl dispatch 'hl.dsp.exit()'
    sleep 2
    if pgrep -x Hyprland >/dev/null; then
        killall -9 Hyprland
    fi
fi