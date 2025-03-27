adr=$(hyprctl -j clients | jq -r '.[] | select(.fullscreen == 2) | .address')

echo $adr

if [ -n "$adr" ]; then
    hyprctl dispatch focuswindow address:$adr
    hyprctl dispatch setfloating
    hyprctl dispatch fullscreen 0
fi

# hyprctl dispatch focuswindow address:$1
# hyprctl dispatch fullscreen 1
# hyprctl dispatch setfloating
