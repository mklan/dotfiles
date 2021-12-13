#!/bin/bash

# bspc rule -a \* -o state=floating && urxvt -e sh -c "bspc node -v 600 300; cmatrix" &
# #bspc rule -a \* -o state=floating && urxvt -e sh -c "bspc node -v -600 300; urxvt -e zsh -ic \"setwallpaper ~/wallpaper/tunnel.jpg; zsh\"" &
# bspc rule -a \* -o state=floating && urxvt -e sh -c "bspc node -v 600 -300; pipes.sh" &
# bspc rule -a \* -o state=floating && urxvt -e sh -c "bspc node -v 500 -200; tty-clock" &

# sleep 5

# zsh -ic "wallpaper ~/wallpaper/tunnel.jpg"

# sleep 5

# zsh -ic "wallpaper ~/wallpaper/trees.jpg"


function toggleScreenKey {
  xdotool key Control_L+Control_R
}

function closeNode {
  xdotool key Alt_L+Shift_L+q
}

function simulateRofiExec {
  xdotool key Super_L+d
  sleep 2
  xdotool type $1
  sleep 1
  xdotool key Escape
}

function enterText {
  toggleScreenKey

  xdotool type "${1}"
  sleep 0.3
  xdotool key Return

  toggleScreenKey
}

function execInTerm {
  xdotool key Super_L+Return
  xdotool click 1

  enterText "${1}"
}


screenkey &

bspc desktop -f 3 # make it where run

sleep 1


# execInTerm 'wallpaper ~/wallpaper/tunnel.jpg'

# pkill screenkey
# exit 1


execInTerm 'gotop'
sleep 0.4
execInTerm 'cmatrix'
sleep 0.4
execInTerm 'tty-clock'
sleep 0.4
execInTerm 'pipes.sh'
sleep 0.4
execInTerm 'cal'
#sleep 0.4
#execInTerm 'cava' # music viz
#sleep 0.4
#execInTerm 'figlet DEMO DEMO' # write asci

sleep 1
xdotool key Super_L+Alt_L+minus
sleep 0.2
xdotool key Super_L+Alt_L+minus
sleep 0.2
xdotool key Super_L+Alt_L+minus
sleep 0.2
xdotool key Super_L+Alt_L+minus
sleep 0.2
xdotool key Super_L+Alt_L+plus
sleep 0.2
xdotool key Super_L+Alt_L+plus
sleep 0.2
xdotool key Super_L+Alt_L+plus
sleep 0.2
xdotool key Super_L+Alt_L+plus

sleep 0.4

xdotool mousemove 150 150
xdotool click 1

sleep 0.2

xdotool key Super_L+e

sleep 1
xdotool key Super_L+e

sleep 1
xdotool key Super_L+e

sleep 0.7


closeNode

sleep 0.7

closeNode

sleep 0.7

execInTerm 'wallpaper ~/wallpaper/tunnel.jpg'

sleep 5

execInTerm 'wallpaper ~/wallpaper/trees.jpg'

enterText "ls -la"




pkill screenkey


# simulateRofiExec 'cmatrix' 
# bspc rule -a \* -o state=floating && urxvt -e zsh -ic "bspc node -v 600 300; cmatrix" &

# sleep 2

# simulateRofiExec 'neofetch' 
# bspc rule -a \* -o state=floating && urxvt -e zsh -ic "bspc node -v -600 -300; neofetch --w3m --source ~/wallpaper/$(wpg -c); zsh" &

# sleep 2

# simulateRofiExec 'tty-clock' 
# bspc rule -a \* -o state=floating && urxvt -e zsh -ic "bspc node -v -600 300; tty-clock" &

# sleep 3



