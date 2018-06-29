#!/bin/bash

function installPackages {
  sudo pacman -S yaourt --noconfirm --needed
  yaourt -Syy \
  i3 \
  rofi \
  terminator \
  polybar \
  --noconfirm --needed
}

function createSymlinks {
  ln -sf $pwd/i3/* ~/.config/i3/
  ln -sf $pwd/polybar/* ~/.config/polybar/
  ln -sf $pwd/rofi/* ~/.config/rofi/
}

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	installPackages
	createSymlinks
  fi
}

main
