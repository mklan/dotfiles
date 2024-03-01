#~/.config/bspwm/spawn_float.sh "urxvt -e zsh -c \"$1\"" $2 $3 $4 $5

~/.config/bspwm/spawn_float.sh "urxvt" $2 $3 $4 $5 &
sleep 0.4
xdotool type "${1}"
xdotool key Return