#!/bin/bash

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	  ./install-list.sh hyprland.packages.json
  fi

  echo "copying helpful util scripts"
  ./copy-scripts.sh

  echo "creating symlinks"
  cd ..
  createSymlinks
  
  
  # sudo systemctl enable --now acpid.service
  # apply throttle fix (throttle pacman package)
  # sudo systemctl enable --now lenovo_fix.service

  # add user to video group (for light control)
  sudo usermod -aG video $USER
  sudo usermod -aG wheel $USER

  echo "setting theme"
  wal --theme ~/.config/wal/colorschemes/dark/everforest_oled.json

  echo "systemctl"

  sudo systemctl enable NetworkManager

  echo "setting zsh as default shell"
  chsh -s $(which zsh)

  echo "done :)"

}


function createSymlinks {

  # dunst pywal theming
  mkdir -p ~/.config/dunst
  ln -sf "${HOME}/.cache/wal/dunstrc" "${HOME}/.config/dunst/dunstrc"

  # create symlinks

  stow config
  stow config-wayland
  
  sudo rm -rf /etc/lemurs/*
  sudo ln -sf lemurs/* /etc/lemurs/

  # patches (keep for now commented out)
  # ln -sf $(pwd)/_patches/mic_mute_external/lenovo-mutemic /etc/acpi/events/lenovo-mutemic
  # sudo ln -sf $(pwd)/_patches/blueman-wheel-priv/51-blueman.rules  /usr/share/polkit-1/rules.d/51-blueman.rules

}

main
