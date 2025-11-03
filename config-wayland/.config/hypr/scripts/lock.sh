#!/bin/bash
. "${HOME}/.cache/wal/colors.sh"

BLANK='#00000000'
CLEAR='#ffffff22'
DEFAULT="${color6}ee"
VERIFYING="${color3}ee"
TYPING="${color5}ee"
WRONG="${color1}ee"


# suspend message display
# source: https://faq.i3wm.org/question/5654/how-can-i-disable-notifications-when-the-screen-locks-and-enable-them-again-when-unlocking/
pkill -u "$USER" -USR1 dunst


# lock the screen
#
swaylock \
	-f \
	--screenshots \
	--indicator \
	--indicator-radius 100 \
	--indicator-thickness 4 \
	--effect-blur 7x5 \
	--effect-vignette 0.5:0.5 \
	--ring-color ${color5} \
	--key-hl-color ${color6} \
	--line-color 00000000 \
	--inside-color 00000000 \
	--separator-color 00000000 \


# resume message display
pkill -u "$USER" -USR2 dunst
