#!/usr/bin/env bash
# Called by dunst via script_action (mouse_middle_click).
# Switches to the Hyprland workspace of the app that sent the notification.

# Dunst sets DUNST_ACTION_NAME when invoked via script_action (mouse click).
# On normal notification display the var is unset — bail out to avoid focusing on every popup.
[ -z "$DUNST_ACTION_NAME" ] && exit 0

find_workspace() {
    local pattern="$1"
    hyprctl clients -j | jq -r \
        --arg p "$pattern" \
        '.[] | select(.class | ascii_downcase | contains($p | ascii_downcase)) | .workspace.id' \
        | grep -v '^-' | head -1
}

# Prefer the desktop-entry name (matches window class most reliably), fall back to app name.
WS=""
if [ -n "$DUNST_DESKTOP_ENTRY" ]; then
    WS=$(find_workspace "$DUNST_DESKTOP_ENTRY")
fi
if [ -z "$WS" ] && [ -n "$DUNST_APP_NAME" ]; then
    WS=$(find_workspace "$DUNST_APP_NAME")
fi

[ -n "$WS" ] && hyprctl dispatch workspace "$WS"
