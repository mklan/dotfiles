wal -q -i ~/wallpaper/

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

