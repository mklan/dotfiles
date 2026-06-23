touch ~/.config/waybar/style.css
wal -l --theme /home/matze/dotfiles/config/.config/wal/colorschemes/dark/everforest_oled.json
cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/style.css
pkill -SIGUSR2 waybar 2>/dev/null || true
pkill dunst 2>/dev/null; dunst &>/dev/null & disown