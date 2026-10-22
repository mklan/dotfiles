#!/bin/bash

URL=https://duck.ai/

# Compute what the assistant size SHOULD be on the currently focused monitor
# (50% x 50%, matching the windowrule).  If an existing window already has
# that size we leave it alone so reloads don't pop it up.  If the size is
# stale (e.g. after undocking) we respawn so the windowrule re-evaluates
# monitor_w / monitor_h for the new resolution.

read -r W H < <(hyprctl monitors -j 2>/dev/null | python3 -c "
import sys, json
for m in json.load(sys.stdin):
    if m.get('focused'):
        print(int(m['width'] / m['scale'] * 0.5), int(m['height'] / m['scale'] * 0.5))
        break
")

if hyprctl clients 2>/dev/null | grep -q "class: assistant"; then
    # Check current size of the assistant window
    read -r CW CH < <(hyprctl clients -j 2>/dev/null | python3 -c "
import sys, json
for c in json.load(sys.stdin):
    if c.get('class') == 'assistant':
        print(c['size'][0], c['size'][1])
        break
")
    if [ "$CW" = "$W" ] && [ "$CH" = "$H" ]; then
        exit 0  # already correct size — do nothing
    fi
    # Stale size (resolution changed) — respawn to re-apply the rule
    pkill -f "76fj82x8.headless"
    sleep 0.5
fi

# Launch assistant Firefox instance. MOZ_APP_REMOTINGNAME sets the Wayland
# app_id to "assistant" so the windowrule can match it (Firefox's --class
# flag only sets X11 WM_CLASS, not the Wayland app_id).
MOZ_APP_REMOTINGNAME=assistant /usr/bin/firefox --profile ~/.mozilla/firefox/76fj82x8.headless --new-instance --class "assistant" $URL & disown

# Wait for window to appear
timeout=10
while [ $timeout -gt 0 ]; do
    if hyprctl clients | grep -q "class: assistant"; then
        break
    fi
    sleep 0.2
    timeout=$((timeout - 1))
done

# Windowrule places it on special:assistant silently with float/size/position.
# It stays invisible until the user presses Super+X to toggle the workspace.
