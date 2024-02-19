timeswaylock=600
timeoff=300


swayidle -w timeout $timeswaylock '~/dotfiles/scripts/lock-wayland.sh' timeout $timeoff 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'

