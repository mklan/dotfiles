#!/usr/bin/env bash
# Toggle pypr scratchpad with smooth animation.
# Uses hyprctl eval (Lua config) to temporarily bump window animation speeds,
# then restores near-instant speeds so normal spawning stays fast.

SPEED=3  # deciseconds — smooth but quick

# Bump speeds for smooth slide
hyprctl eval "hl.animation({ leaf = 'windowsIn',    enabled = true, speed = ${SPEED}, bezier = 'easeOutQuint', style = 'popin 80%' })" >/dev/null
hyprctl eval "hl.animation({ leaf = 'windowsOut',   enabled = true, speed = ${SPEED}, bezier = 'easeOutQuint', style = 'popin 80%' })" >/dev/null
hyprctl eval "hl.animation({ leaf = 'windowsMove',  enabled = true, speed = ${SPEED}, bezier = 'easeOutQuint' })" >/dev/null

pypr toggle term

sleep 0.5

# Restore near-instant speeds
hyprctl eval "hl.animation({ leaf = 'windowsIn',    enabled = true, speed = 0.1, bezier = 'easeOutQuint', style = 'popin 80%' })" >/dev/null
hyprctl eval "hl.animation({ leaf = 'windowsOut',   enabled = true, speed = 0.1, bezier = 'easeOutQuint', style = 'popin 80%' })" >/dev/null
hyprctl eval "hl.animation({ leaf = 'windowsMove',  enabled = true, speed = 0.1, bezier = 'easeOutQuint' })" >/dev/null
