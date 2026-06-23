#!/bin/bash
# Focus the workspace where Firefox is open, or launch Firefox if not running

FIREFOX_LC_REGEX="(?i)firefox"
# Matches keywords indicating a private browsing window in titles
PRIVATE_LC_REGEX="(?i)private|private browsing|private window"

# Optional flag: --private to target private windows only when focusing/launching
LAUNCH_PRIVATE=false
if [ "$1" = "--private" ]; then
    LAUNCH_PRIVATE=true
fi

if [ "$LAUNCH_PRIVATE" = true ]; then
    # Only consider Firefox windows whose title indicates a private window
    WORKSPACE=$(hyprctl clients -j | jq -r \
      ".[] | select(((.class // \"\") | test(\"$FIREFOX_LC_REGEX\")) or ((.app_id // \"\") | test(\"$FIREFOX_LC_REGEX\")) or ((.title // \"\") | test(\"$FIREFOX_LC_REGEX\"))) | select((.title // \"\") | test(\"$PRIVATE_LC_REGEX\")) | select(.workspace.id > 0) | .workspace.id" | head -n1)
    if [ -n "$WORKSPACE" ]; then
        hyprctl dispatch workspace "$WORKSPACE"
    else
        firefox -private-window &
    fi
else
    # Exclude private windows — only normal Firefox windows trigger workspace switch
    WORKSPACE=$(hyprctl clients -j | jq -r \
      ".[] | select(((.class // \"\") | test(\"$FIREFOX_LC_REGEX\")) or ((.app_id // \"\") | test(\"$FIREFOX_LC_REGEX\")) or ((.title // \"\") | test(\"$FIREFOX_LC_REGEX\"))) | select((.title // \"\") | test(\"$PRIVATE_LC_REGEX\") | not) | select(.workspace.id > 0) | .workspace.id" | head -n1)

    if [ -n "$WORKSPACE" ]; then
        hyprctl dispatch workspace "$WORKSPACE"
    else
        firefox &
    fi
fi
