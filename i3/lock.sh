#!/bin/bash
# https://faq.i3wm.org/question/5654/how-can-i-disable-notifications-when-the-screen-locks-and-enable-them-again-when-unlocking/
# suspend message display
pkill -u "$USER" -USR1 dunst

# lock the screen
i3lock-fancy-rapid 5 3 -n

# TODO: create wal template
# i3lock-fancy-rapid 5 3 -n --ringcolor=ffffffff --ringwrongcolor=ffffffff --keyhlcolor=d23c3dff --insidevercolor=fecf4dff --insidewrongcolor=d23c3dff --veriftext="" --wrongtext=""
# i3lock -n -i $XDG_DATA_HOME/wallpapers/wallpaper_lock.png \
#     --insidecolor=373445ff --ringcolor=ffffffff --line-uses-inside \
#     --keyhlcolor=d23c3dff --bshlcolor=d23c3dff --separatorcolor=00000000 \
#     --insidevercolor=fecf4dff --insidewrongcolor=d23c3dff \
#     --ringvercolor=ffffffff --ringwrongcolor=ffffffff --indpos="x+86:y+1003" \
#     --radius=15 --veriftext="" --wrongtext=""

# resume message display
pkill -u "$USER" -USR2 dunst