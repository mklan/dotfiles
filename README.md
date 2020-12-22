# .dotfiles

arch system configuration using bspwm as the window manager

![Desktop Screenshot](https://github.com/mklan/dotfiles/blob/master/screenshots/desktop.jpg)

![Desktop Screenshot 2](https://github.com/mklan/dotfiles/blob/master/screenshots/rofi.jpg)

`setwallpaper ~/path/to/some/wallpaper.jpg`

![Theme switching](https://github.com/mklan/dotfiles/blob/master/screenshots/demo.gif)

## Core system dependencies

- bspwm
- sxhkd
- polybar
- rofi
- dunst
- urxvt
- zsh
- vim
- i3-lock
- autorandr
- picom-tryone-git
- wpg

For a complete list look into `dependencies.txt`

## Install

> **Warning!** This is a highly customized install for my system (ThinkPad t480s). The install script is very basic and hacked together. Use at your own risk! Preferably just pick the config files one by one.

`./install.sh /path/to/your/wallpaper.jpg`.

## Possible Fixes

### Firefox tearing / preformance

set `layers.acceleration.force-enabled` to true in `about:config`
