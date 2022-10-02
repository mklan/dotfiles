RECT=$(~/.config/bspwm/calc_rectangle.sh $2 $3 $4 $5)

bspc rule -a \* -o state=floating sticky=on rectangle=$RECT && $1

# urxvt -e zsh -ic "gtop"s