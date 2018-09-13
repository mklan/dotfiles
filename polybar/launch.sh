#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# get primary monitor
export MONITOR=$(xrandr -q | grep " connected primary" | cut -d ' ' -f1)

# Launch bar
polybar bar &

echo "Polybars launched..."
