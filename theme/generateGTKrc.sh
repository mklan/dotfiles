#!/bin/sh
#this script alters the wal-arc-dark theme in order to replace the blue accents with a pywal color

source $HOME/.cache/wal/colors.sh


#set pywal accentColor here [0-15]
accentColor=$color1

sed -i "/gtk-color-scheme = \"selected_bg_color:*/c\gtk-color-scheme = \"selected_bg_color: ${accentColor}\"" $HOME/.themes/wal-arc-dark/gtk-2.0/gtkrc

sed -i "/gtk-color-scheme = \"link_color:*/c\gtk-color-scheme = \"link_color: ${accentColor}\"" $HOME/.themes/wal-arc-dark/gtk-2.0/gtkrc
