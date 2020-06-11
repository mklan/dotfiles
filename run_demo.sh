#!/bin/bash

bspc desktop -f 4
bspc rule -a \* -o state=floating && urxvt -e sh -c "bspc node -v -600 -300; neofetch --w3m --source ~/wallpaper/$(wpg -c); zsh" &
bspc rule -a \* -o state=floating && urxvt -e sh -c "bspc node -v 600 300; cmatrix" &
bspc rule -a \* -o state=floating && urxvt -e sh -c "bspc node -v -600 300; pipes.sh" &
# wpg -s tunnel.jpg