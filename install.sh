#!/bin/bash

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	installPackages
  fi
  
  createSymlinks
}

function installPackages {
  # install basic dependencies
  sudo pacman -S --noconfirm --needed base-devel git wget yajl
  
  installAurman

  # install additional packages
  aurman -S --noconfirm --needed --skip_news $(cat ./package_list.txt)
}

function createSymlinks {
  ln -sf $(pwd)/i3/* ~/.config/i3/
  ln -sf $(pwd)/polybar/* ~/.config/polybar/
  ln -sf $(pwd)/rofi/* ~/.config/rofi/
}

function installAurman {
  git clone https://aur.archlinux.org/aurman.git
  cd aurman
  makepkg -si --skipinteg --noconfirm --needed
  cd ..
  rm -rf aurman
}

main
