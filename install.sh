#!/bin/bash

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	  installList './arch-pkglist'
  fi

  # install theme
  wpg-install.sh -g -i
  wpg -s ${1}
 
  ./install/copy-scripts.sh


  createSymlinks
  installZsh

  ./systemd/setup.sh
  
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
        installList './apps_pkglist'
  fi

}

function installList {
  # install basic dependencies
  sudo pacman -S --noconfirm --needed base-devel git wget yajl dialog
  
  # TODO make optional
  installYay

  # install packages from passed list
  selection=$(sudo ./install/list-select.sh $1 "Select to install")

  yay -S --noeditmenu --nodiffmenu --nocleanmenu --noconfirm ${selection}
}

function installZsh {
  # install oh my zsh
  wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

  # switch to zsh
  chsh -s /usr/bin/zsh $USER
  # install zsh plugins
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  # themes
  yay -S --noeditmenu --nodiffmenu --nocleanmenu --noconfirm zsh-theme-powerlevel10k-git
}

function createSymlinks {

  # just in case
  mv ~/.config/neofetch/config.conf ~/.config/neofetch/config.conf.bak

  # create symlinks
  stow config

  # dunst pywal theming
  ln -sf "${HOME}/.cache/wal/dunstrc" "${HOME}/.config/dunst/dunstrc"
  
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

main
