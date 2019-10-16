# .dotfiles

arch system configuration using i3 as window manager

![Desktop Screenshot](https://github.com/mklan/dotfiles/blob/master/screenshots/desktop.jpg)


## Utilized packages / applications / tools

> __Warning!__ The list is not complete! For a complete list look into `package_list.txt`

- i3
- polybar
- rofi
- compton
- feh
- wal
- flameshot
- xbacklight
- pamixer
- urxvt
- zsh

## Install

1. Set your wallpaper in the first line of `./i3/config` and run `./install.sh`.

## Fixes

### Firefox tearing / preformance

set `layers.acceleration.force-enabled` to true in `about:config`

## TODO

- [x] Open source
- [x] Proper install script
- [x] auto install dependencies for arch
- [x] add vim config
- [x] add $ZDOTDIR/.zshrc
- [ ] (automate) screenshots of resulting setup
- [x] add proper install description to readme
- [ ] auto generate documentation of shortcuts

05.2019

- [ ] document via gif
