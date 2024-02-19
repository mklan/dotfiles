wal -q -i ~/wallpaper/

source "$HOME/.cache/wal/colors.sh"

cp $wallpaper ~/.cache/current_wallpaper.jpg

# get wallpaper name
newwall=$(echo $wallpaper | sed "s|$HOME/wallpaper/||g")


swww img $wallpaper \
    --transition-bezier .43,1.19,1,.4 \
    --transition-fps=120 \
    --transition-step=90 \
    --transition-type="random" \
    --transition-duration=0.7 \
    --transition-pos "$( hyprctl cursorpos )"

