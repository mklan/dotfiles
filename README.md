# .dotfiles

Configuration of my arch system running xfce4 as desktop manager and i3 as window manager 

> __Warning!__ This repository is currently in an early pre-alpha state. The configuration is not yet easy to setup

## Utilized packages / applications / tools

> __Warning!__ The list is not complete!

- i3
- xfce4
- polybar
- rofi
- compton
- nitrogen
- wal
- Arc-Dark [GTK2 Theme] 
- Vertex-Maia [GTK2 Icons] 
- flameshot
- xbacklight
- pamixer
- terminator
- zsh

## Install

> __Warning!__ the background setting is not working right now and is hardcoded in i3

First make sure to specify the path of your wallpaper as an environment variable:

```bash
export I3_BACKGROUND=$HOME/wallpapers/desktop_space.jpeg
```

After that run `./install.sh`.

Finally, install all the missing packages which are not defined in the script yet.

> ___TODO___ add instruction to somehow set the settings in xfce4 in order to be able to use i3 in coexistence

## Dependencies

## TODO

- [x] Open source
- [x] Proper install script
- [x] auto install dependencies for arch
- [ ] add .vimrc
- [ ] add $ZDOTDIR/.zshrc
- [ ] (automate) screenshots of resulting setup
- [ ] add proper install description to readme
- [ ] auto generate documentation of shortcuts
