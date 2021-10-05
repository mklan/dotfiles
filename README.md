# .dotfiles

GNU/Linux system configuration using bspwm as window manager

![Desktop Screenshot](https://github.com/mklan/dotfiles/blob/master/screenshots/desktop.jpg)

![Desktop Screenshot 2](https://github.com/mklan/dotfiles/blob/master/screenshots/rofi.jpg)

`wallpaper ~/path/to/some/wallpaper.jpg`

![Theme switching](https://github.com/mklan/dotfiles/blob/master/screenshots/demo.gif)

## Core system components

- bspwm
- sxhkd
- polybar
- rofi
- dunst
- urxvt
- zsh
- i3-lock
- picom
- wpg

For a complete list look into `arch-pkglist`

## Install ( arch-linux )

> **Warning!** This is a highly customized install for my system (ThinkPad t480s). The install script is very basic and hacked together. Use at your own risk! Preferably just pick the config files one by one.

`./install.sh /path/to/your/wallpaper.jpg`.

## Usage

press `super + return` to open terminal

press `super + d` to open app launcher

press `alt + shift + q` to close window

press `super + [0-9]` to switch desktops

press `super + h` to display rest of the key-bindings

## Misc

### Add open in new terminal to Thunar

Thunar -> Edit -> Configure custom actions...

Open in new Terminal: `sh -c 'cd %f;urxvt'`

## Troubleshooting

### Firefox tearing / preformance

set `layers.acceleration.force-enabled` to true in `about:config`

### Blueman does not open Devices

to fix run:

`dbus-update-activation-environment DISPLAY`
