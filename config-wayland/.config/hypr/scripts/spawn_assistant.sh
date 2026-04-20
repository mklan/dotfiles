#!/bin/bash
#firefox --no-remote -ProfileManager


#URL=https://copilot.microsoft.com
#URL=https://www.deepseek.com/
#URL=https://chatgpt.com/
URL=https://duck.ai/

pkill -f "76fj82x8.headless" 

sleep 0.5

/usr/bin/firefox --profile ~/.mozilla/firefox/76fj82x8.headless --new-instance --kiosk --class "assistant" $URL & disown

# Wait for window to appear
timeout=10
while [ $timeout -gt 0 ]; do
    if hyprctl clients | grep -q "class: assistant"; then
        break
    fi
    sleep 0.2
    timeout=$((timeout - 1))
done

# Toggle floating mode
hyprctl dispatch togglefloating
hyprctl dispatch resizeactive exact 960 540
hyprctl dispatch centerwindow

# Toggle special workspace assistant
hyprctl dispatch togglespecialworkspace assistant


