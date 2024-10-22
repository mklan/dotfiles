#!/bin/bash
#firefox --no-remote -ProfileManager

/usr/bin/firefox --profile ~/.mozilla/firefox/76fj82x8.headless --new-instance --kiosk --class "copilot" https://copilot.microsoft.com & disown

sleep 5

