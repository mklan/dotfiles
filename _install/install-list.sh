#!/bin/bash

function installList {

# install basic dependencies
  sudo pacman -S --noconfirm --needed base-devel git wget yajl dialog
  
  installYay

  # install packages from passed list
  selection=$(./list-select.ts $1)


  yay -S --noconfirm ${selection}
}

function installYay {
  if ! command -v "yay" &> /dev/null
  then
    echo "yay not found! will install ..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --skipinteg --noconfirm --needed
    cd ..
    rm -rf yay
  fi
}

installList $1