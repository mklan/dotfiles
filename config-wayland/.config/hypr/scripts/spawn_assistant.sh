#!/bin/bash
#firefox --no-remote -ProfileManager


#URL=https://copilot.microsoft.com
#URL=https://www.deepseek.com/
#URL=https://chatgpt.com/
URL=https://duck.ai/

pkill -f "76fj82x8.headless" 

sleep 0.5

# Launch assistant Firefox instance without kiosk/fullscreen; Hypr windowrules will
# place it on the special workspace and set floating/size/position silently.
#!/bin/bash
# Launch assistant Firefox instance in kiosk mode (fullscreen) but do not
# toggle the special workspace here — autostart places it on the special
# workspace silently and windowrules.conf will float/size/move it.
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

# We rely on windowrules.conf to float/size/move the assistant window and
# the autostart entry to place it on the special workspace silently. Do not
# toggle the workspace here so it remains invisible until the user presses
# Super+X to show it.


