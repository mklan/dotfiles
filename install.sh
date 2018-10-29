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

	# needs testing, creates local config somehow 
#	symlinks=( "$(pwd)/i3/*:~/.config/i3/"
#		"$(pwd)/polybar/*:~/.config/polybar/"
#		"$(pwd)/rofi/*:~/.config/rofi/"
#		"$(pwd)/terminator/*:~/.config/terminator/"
#		"$(pwd)/wallpaper/*:~/wallpaper/"
#		"$(pwd)/autorandr/*:~/.autorandr/"
##		)
#
#	for symlink in "${symlinks[@]}" ; do
#	    src="${symlink%%:*}"
#	    dest="${symlink##*:}"
#
#	    mkdir -p $dest
#	    ln -sf $src $dest
#	done
#

  mkdir -p ~/.config/i3
  ln -sf $(pwd)/i3/* ~/.config/i3/

  mkdir -p ~/.config/Code/User/snippets
  ln -sf $(pwd)/vscode/snippets/* ~/.config/Code/User/snippets/
  
  mkdir -p ~/.config/polybar
  ln -sf $(pwd)/polybar/* ~/.config/polybar/
  
  mkdir -p ~/.config/rofi
  ln -sf $(pwd)/rofi/* ~/.config/rofi/

  mkdir -p ~/.config/terminator
  ln -sf $(pwd)/terminator/* ~/.config/terminator/

  mkdir -p ~/wallpaper
  ln -sf $(pwd)/wallpaper/* ~/wallpaper/

  mkdir -p ~/.autorandr
  ln -sf $(pwd)/autorandr/* ~/.autorandr/
  
  mkdir -p ~/.vim
  ln -sf $(pwd)/vim/* ~/.vim/

  mkdir -p ~/.devilspie
  ln -sf $(pwd)/devilspie/* ~/.devilspie/

  ln -sf $(pwd)/common/.* ~/

  mkir -p ~/.themes
  ln -sf $(pwd)/theme/* ~/.themes/
}

function installAurman {
  git clone https://aur.archlinux.org/aurman.git
  cd aurman
  makepkg -si --skipinteg --noconfirm --needed
  cd ..
  rm -rf aurman
}

main
