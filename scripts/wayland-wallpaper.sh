# -s: never write escape sequences to /dev/pts/* – a stale pty master with a
# full output queue blocks wal forever (see switch-theme.sh)
wal -q -s -i ~/wallpaper/

source "$HOME/.cache/wal/colors.sh"

cp $wallpaper ~/.cache/current_wallpaper.jpg

# get wallpaper name
newwall=$(echo $wallpaper | sed "s|$HOME/wallpaper/||g")


swww img $wallpaper \
    --transition-fps=60 \
    --transition-step=90 \
    --transition-type="wipe" \
    --transition-duration=1.4 \
    --transition-pos "$( hyprctl cursorpos )"

