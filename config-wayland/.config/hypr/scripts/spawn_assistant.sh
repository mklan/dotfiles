#!/bin/bash
#firefox --no-remote -ProfileManager


#URL=https://copilot.microsoft.com
URL=https://www.deepseek.com/

/usr/bin/firefox --profile ~/.mozilla/firefox/76fj82x8.headless --new-instance --kiosk --class "assistant" $URL & disown

sleep 5

