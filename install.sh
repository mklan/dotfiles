#!/bin/bash

function installPackages {
  echo ' ' >> /etc/pacman.conf
  echo '[archlinuxfr]' >> /etc/pacman.conf
  echo 'SigLevel = Never' >> /etc/pacman.conf
  echo 'Server = http://repo.archlinux.fr/$arch' >> /etc/pacman.conf

  sudo pacman -Sy yaourt --noconfirm --needed
  
  # install basic dependencies
  sudo pacman -S --noconfirm base-devel git wget yajl

  # install additional packages
  yaourt --noconfirm --needed - < package_list.txt 
}

function createSymlinks {
  ln -sf $(pwd)/i3/* ~/.config/i3/
  ln -sf $(pwd)/polybar/* ~/.config/polybar/
  ln -sf $(pwd)/rofi/* ~/.config/rofi/
}

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	installPackages
  fi
  
  createSymlinks
}

main
