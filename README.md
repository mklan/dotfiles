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
- wpgtk

For a complete list look into `arch-pkglist`

## Features

`ctrl + alt + super + c` vscode projects launcher

`ctrl + alt + super + brightnessUp` set max brightness

`ctrl + alt + super + brightnessDown` set lowest brightness

`super + k` toggle KeepassXC



## Install (arch-linux)

> **Warning!** This is a highly customized install script for my machine (ThinkPad t480s). It will propably break something on your system! Preferably just cherrypick the config files.

`./install.sh /path/to/your/wallpaper.jpg`.

## Usage

press `ctrl + alt + super + return` to open terminal

press `alt + super + return` to open bottom overlay terminal

press `super + d` to open app launcher

press `alt + shift + q` to close window

press `super + [0-9]` to switch desktops

press `super + h` to display rest of the key-bindings


## notes do not commit yet

- explain super key combination (in favor to mac yabai)
    - document ( blog ) how to run yabai and bspwm
- document and fix popup terminal ( find proper name)
- more gif demos of controls ( spawning , switching mouse context, gaps)
- document more in general by showing features of this config (high potential, if everyone understands how amazing this system is)
    - document this awesome piece: ./config/.config/bspwm/spawn_float_terminal.sh gtop 1000 1200 -100 50 &
- clean screenshots to demo
- find wallpaper that fits theme 
- make current green forest theme default but enable pywal stuff
- help menu action execution
- more focus on the workflow, since it is super efficient
- description why it is efficient