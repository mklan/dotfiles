#!/bin/bash

function main {
  read -p "Do you want to install the required packages (arch only) [y/N]?" -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
	  installList './dependencies.txt'
    # install theme
    wpg-install.sh -g -b -d -i
    wpg -s ${1}
  fi

  createSymlinks
  
  # disable lightdm to use startx at startup
  systemctl disable lightdm.service
  
  sudo systemctl enable --now acpid.service
  # apply throttle fix (throttle pacman package)
  sudo systemctl enable --now lenovo_fix.service


  # install oh my zsh
  wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

  # switch to zsh
  chsh -s /usr/bin/zsh $USER
  # install zsh plugins
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


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

}

function installList {
  # install basic dependencies
  sudo pacman -S --noconfirm --needed base-devel git wget yajl dialog
  
  # todo figure out optional
  installAurman

  # install packages from passed list
  selection=sudo ./install/list-select.sh $1 "Select to install"
  aurman -S --noedit --noconfirm --needed --skip_news $selection
}

function createSymlinks {

  mv ~/.config/neofetch/config.conf ~/.config/neofetch/config.conf.bak
  stow neofetch

  stow bspwm sxhkd polybar autorandr i3 vim rofi picom ranger wpg
  
  ln -sf $(pwd)/_patches/mic_mute_external/lenovo-mutemic /etc/acpi/events/lenovo-mutemic

  mkdir -p ~/wallpaper
  ln -sf $(pwd)/wallpaper/* ~/wallpaper/

  ln -sf $(pwd)/common/.* ~/

  sudo mkdir -p /etc/X11/xorg.conf.d
  sudo ln -sf $(pwd)/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/

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

  sudo mkdir -p /etc/systemd/system
  sudo ln -sf $(pwd)/i3/i3lock.service /etc/systemd/system/i3lock.service

  sudo ln -sf $(pwd)/bluetooth/51-blueman.rules  /usr/share/polkit-1/rules.d/51-blueman.rules

}

function installAurman {
  if ! command -v "aurman" &> /dev/null
  then
    echo "aurman not found"
    git clone https://aur.archlinux.org/aurman.git
    cd aurman
    makepkg -si --skipinteg --noconfirm --needed
    cd ..
    rm -rf aurman
  fi

}

main
