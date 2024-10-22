# .dotfiles

GNU/Linux system configuration using Hyprland as compositor (Legacy Mode: bspwm)

## Features

### AI prompt scratchpad

Instant access to your prefered prompt

![Theme switching](https://github.com/mklan/dotfiles/blob/master/screenshots/ai_prompt.gif)

### Code Project launcher

Quickly launch projects

![Theme switching](https://github.com/mklan/dotfiles/blob/master/screenshots/project-launcher.gif)

### Theme generation

`setTheme ~/path/to/some/wallpaper.jpg`

![Theme switching](https://github.com/mklan/dotfiles/blob/master/screenshots/wallpaper_switch.gif)


TODO: Create demos for more features.

## Core system components

- kitty
- zsh
- rofi
- dunst

### Wayland

- Hyprland
- waybar
- wlogout

### X11 (Legacy)

- bspwm
- polybar
- picom
- pywal
- sxhkd
- i3-lock

For a complete list look into `_install/arch-pkglist`

## Commands

`hypr = ctrl + alt + super`

`hypr + return` open terminal

`super + d` app launcher

`strg + [0-9]` to switch desktops

`hypr + [0-9]` send to window + switch

`hypr + arrow` switch focus

`ctrl + super + arrow` swap windows

`super + q` close focused window

`super + c` vscode projects launcher

`super + k` toggle KeepassXC

`super + a` toggle sticky kitty

`hypr + brightnessUp` set max brightness

`hypr + brightnessDown` set min brightness


Legacy Mode:

`alt + super + return` to open bottom overlay terminal (bspwm only)

`super + h` display rest of the key-bindings
