# .dotfiles

arch system configuration using bspwm as window manager

![Desktop Screenshot](https://github.com/mklan/dotfiles/blob/master/screenshots/desktop.jpg)

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

## Apply new Theme

`setwallpaper /path/to/some-other/wallpaper.jpg`

## Fixes

### Firefox tearing / preformance

set `layers.acceleration.force-enabled` to true in `about:config`

## TODO

- [x] Open source
- [x] Proper install script
- [x] auto install dependencies for arch
- [x] add vim config
- [x] add \$ZDOTDIR/.zshrc
- [ ] (automate) screenshots of resulting setup
- [x] add proper install description to readme
- [ ] auto generate documentation of shortcuts

  05.2019

- [ ] document via gif
