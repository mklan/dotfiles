#!/bin/bash

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	  ./install-list.sh hyprland.packages.json
  fi

  ./copy-scripts.sh


  createSymlinks
  
  
  # sudo systemctl enable --now acpid.service
  # apply throttle fix (throttle pacman package)
  # sudo systemctl enable --now lenovo_fix.service

  # add user to video group (for light control)
  sudo usermod -aG video $USER
  sudo usermod -aG wheel $USER
}


function createSymlinks {

  # dunst pywal theming
  ln -sf "${HOME}/.cache/wal/dunstrc" "${HOME}/dotfiles/config/.config/dunst/dunstrc"

  # create symlinks

  cd ..

  stow config
  stow config-wayland
  
  sudo rm /etc/lemurs/*
  sudo ln -sf lemurs/* /etc/lemurs/

  # patches (keep for now commented out)
  # ln -sf $(pwd)/_patches/mic_mute_external/lenovo-mutemic /etc/acpi/events/lenovo-mutemic
  # sudo ln -sf $(pwd)/_patches/blueman-wheel-priv/51-blueman.rules  /usr/share/polkit-1/rules.d/51-blueman.rules

}

main
