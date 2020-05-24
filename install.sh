#!/bin/bash

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	  installList './package_list.txt'
    # install theme
    wpg-install.sh -g -b -d -i
    wpg -s ${1}
  fi

  createSymlinks
  
  # disable lightdm to use startx at startup
  systemctl disable lightdm.service

  # apply throttle fix (throttle pacman package)
  sudo systemctl enable --now lenovo_fix.service


  # install oh my zsh
  wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

  # switch to zsh
  chsh -s /usr/bin/zsh $USER

  # get vscode pywal theme
  
  # git clone https://github.com/Bluedrack28/vscode-wal.git ~/.vscode-oss/extensions/vscode-wal

  # install node version manager
  # curl -L https://git.io/n-install | bash

  # install additionall apps

  read -p "Do you want to install additional apps (arch only) [y/N]?" -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]
  then
        installList './apps_list.txt'
  fi


  # add user to video group (for light control)
  sudo usermod -aG video $USER
  sudo usermod -aG wheel $USER
  sudo pip install i3-py

}

function installList {
  # install basic dependencies
  sudo pacman -S --noconfirm --needed base-devel git wget yajl
  
  installAurman

  # install additional packages
  aurman -S --noedit --noconfirm --needed --skip_news $(sed -e '/^#/d' $1)
}

function createSymlinks {

  stow bspwm sxhkd polybar autorandr i3 vim rofi picom ranger
  
  mkdir -p ~/wallpaper
  ln -sf $(pwd)/wallpaper/* ~/wallpaper/

  ln -sf $(pwd)/common/.* ~/

  mkdir -p /etc/X11/xorg.conf.d
  ln -sf $(pwd)/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/

#  profileFolder=$(ls $HOME/.mozilla/firefox/ | grep .default)
#  ln -sf $(pwd)/firefox/* ~/.mozilla/firefox/$profileFolder/

  mkdir -p ~/.themes
  ln -sf $(pwd)/theme/* ~/.themes/

  mkdir -p $HOME/.config/wal/templates
  ln -sf $(pwd)/wal/templates/* $HOME/.config/wal/templates/
  
  ln -sf $(pwd)/wal/templates/.Xdefaults $HOME/.config/wal/templates/.Xdefaults
  ln -sf $HOME/.cache/wal/.Xdefaults ~/

 # ln -sf $(pwd)/wal/templates/.Xdefaults $HOME/.config/wal/templates/.Xresources
 # ln -sf $HOME/.cache/wal/.Xresources ~/

  # touch $HOME/.cache/wal/dunstrc
  # mkdir -p $HOME/.config/dunst/
  # ln -sf $HOME/.cache/wal/dunstrc $HOME/.config/dunst/dunstrc

  mkdir -p ~/.config/fusuma/
  ln -sf $(pwd)/fusuma/* $HOME/.config/fusuma/
  sudo gpasswd -a $USER input

  mkdir -p $HOME/.todo
  ln -sf $(pwd)/todo/* $HOME/.todo/

  mkdir -p /etc/systemd/system
  ln -sf $(pwd)/i3/i3lock.service /etc/systemd/system/i3lock.service

  ln -sf $(pwd)/bluetooth/51-blueman.rules  /usr/share/polkit-1/rules.d/51-blueman.rules

}

function installAurman {
  git clone https://aur.archlinux.org/aurman.git
  cd aurman
  makepkg -si --skipinteg --noconfirm --needed
  cd ..
  rm -rf aurman
}

main
