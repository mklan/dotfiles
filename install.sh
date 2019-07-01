#!/bin/bash

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	installList './package_list.txt'
  fi

  createSymlinks
  
  # disable lightdm to use startx at startup
  systemctl disable lightdm.service

  # install oh my zsh
  wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

  # switch to zsh
  chsh -s /usr/bin/zsh $USER

  # get vscode pywal theme
  git clone https://github.com/Bluedrack28/vscode-wal.git ~/.vscode-oss/extensions/vscode-wal

  # install node version manager
  curl -L https://git.io/n-install | bash

  # install additionall apps

  read -p "Do you want to install additional apps (arch only) [y/N]?" -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]
  then
        installList './apps_list.txt'
  fi




}

function installList {
  # install basic dependencies
  sudo pacman -S --noconfirm --needed base-devel git wget yajl
  
  installAurman

  # install additional packages
  aurman -S --noedit --noconfirm --needed --skip_news $(cat $1)
}

function createSymlinks {

  mkdir -p ~/.config/i3
  ln -sf $(pwd)/i3/* ~/.config/i3/

  mkdir -p ~/.config/Code/User/snippets
  ln -sf $(pwd)/vscode/snippets/* ~/.config/Code/User/snippets/
  
  mkdir -p ~/.config/polybar
  ln -sf $(pwd)/polybar/* ~/.config/polybar/
  
  mkdir -p ~/.config/terminator
  ln -sf $(pwd)/terminator/* ~/.config/terminator/

  mkdir -p ~/wallpaper
  ln -sf $(pwd)/wallpaper/* ~/wallpaper/

  mkdir -p ~/.config/autorandr
  ln -sf $(pwd)/autorandr/* ~/.config/autorandr/
  
  mkdir -p ~/.vim
  ln -sf $(pwd)/vim/* ~/.vim/

  mkdir -p ~/.devilspie
  ln -sf $(pwd)/devilspie/* ~/.devilspie/

  ln -sf $(pwd)/common/.* ~/

  profileFolder=$(ls $HOME/.mozilla/firefox/ | grep .default)
  ln -sf $(pwd)/firefox/* ~/.mozilla/firefox/$profileFolder/

  mkdir -p ~/.themes
  ln -sf $(pwd)/theme/* ~/.themes/

  mkdir -p $HOME/.config/wal/templates
  ln -sf $(pwd)/wal/templates/* $HOME/.config/wal/templates/
  
  ln -sf $(pwd)/wal/templates/.Xdefaults $HOME/.config/wal/templates/.Xdefaults
  ln -sf $HOME/.cache/wal/.Xdefaults ~/

 # ln -sf $(pwd)/wal/templates/.Xdefaults $HOME/.config/wal/templates/.Xresources
 # ln -sf $HOME/.cache/wal/.Xresources ~/

  touch $HOME/.cache/wal/dunstrc
  mkdir -p $HOME/.config/dunst/
  ln -sf $HOME/.cache/wal/dunstrc $HOME/.config/dunst/dunstrc

 
  mkdir -p ~/.config/rofi
  ln -sf $HOME/.cache/wal/rofi/* ~/.config/rofi/

  mkdir -p ~/.config/fusuma/
  ln -sf $(pwd)/fusuma/* $HOME/.config/fusuma/
  sudo gpasswd -a $USER input

  mkdir -p $HOME/.todo
  ln -sf $(pwd)/todo/* $HOME/.todo/

  mkdir -p /etc/systemd/system
  ln -sf $(pwd)/i3/i3lock.service /etc/systemd/system/i3lock.service

  mkdir -p ~/.config
  ln -sf $(pwd)/compton/compton.conf ~/.config/compton.conf

}

function installAurman {
  git clone https://aur.archlinux.org/aurman.git
  cd aurman
  makepkg -si --skipinteg --noconfirm --needed
  cd ..
  rm -rf aurman
}

main
