#!/bin/bash

ln -s i3/config ~/.config/i3/config
ln -s polybar/config ~/.config/polybar/config
ln -s rofi/config ~/.config/rofi/config


read -p "Do you want to install the required packages (arch)?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
   installPackages
fi

function installPackages {
  sudo pacman -S yaourt --no-confirm
  yaourt -Syy \
  i3\
  #xfce4\
  rofi\
  terminator\
  polybar\
  # ...
  -no-confirm
}
