#!/bin/bash

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	  ./install-list.sh './arch-pkglist'
  fi

  # install theme
  wpg-install.sh -g -i
  wpg -s ${1}
 
  ./copy-scripts.sh


  createSymlinks

  ../systemd/setup.sh
  
  # disable lightdm to use startx at startup
  systemctl disable lightdm.service
  
  sudo systemctl enable --now acpid.service
  # apply throttle fix (throttle pacman package)
  sudo systemctl enable --now lenovo_fix.service


  # add user to video group (for light control)
  sudo usermod -aG video $USER
  sudo usermod -aG wheel $USER

  # get vscode pywal theme
  # git clone https://github.com/Bluedrack28/vscode-wal.git ~/.vscode-oss/extensions/vscode-wal

  # install additional apps

  read -p "Do you want to install additional apps (arch only) [y/N]?" -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]
  then
        ./install-list.sh './apps_pkglist'
  fi

}


function createSymlinks {

  # just in case
  mv ~/.config/neofetch/config.conf ~/.config/neofetch/config.conf.bak

  # dunst pywal theming
  ln -sf "${HOME}/.cache/wal/dunstrc" "${HOME}/dotfiles/config/.config/dunst/dunstrc"

  # create symlinks
  stow config
  
  sudo ln -sf lemurs/* /etc/lemurs/

  sudo mkdir -p /etc/X11/xorg.conf.d
  sudo ln -sf $(pwd)/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/

#  profileFolder=$(ls $HOME/.mozilla/firefox/ | grep .default)
#  ln -sf $(pwd)/firefox/* ~/.mozilla/firefox/$profileFolder/

  # fusuma (touchpad gesture) needs this 
  sudo gpasswd -a $USER input


 # patches
  ln -sf $(pwd)/_patches/mic_mute_external/lenovo-mutemic /etc/acpi/events/lenovo-mutemic
  sudo ln -sf $(pwd)/_patches/blueman-wheel-priv/51-blueman.rules  /usr/share/polkit-1/rules.d/51-blueman.rules

}

main
