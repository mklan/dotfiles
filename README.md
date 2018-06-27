# .dotfiles

Configuration of my arch system running xfce4 as desktop manager and i3 as window manager 

> __Warning!__ This repository is currently in an early pre-alpha state. The configuration is not easy to setup, due to the many dependencies which must be installed.

## Dependencies

> __Warning!__ The list ist no complete!

- i3
- xfce4
- polybar
- rofi
- compton
- nitrogen
- wal
- flameshot
- xbacklight
- pactl
- pamixer
- terminator
- zsh

## Install

First make sure to specify the path of your wallpaper as an environment variable:

```bash
export I3_BACKGROUND=$HOME/wallpapers/desktop_space.jpeg
```

And than run `./install.sh`

install all the missing dependencies

## Dependencies

## TODO

- [x] Open source
- [ ] Proper install script
    - [ ] auto install dependencies for arch
- [ ] add .vimrc
- [ ] add $ZDOTDIR/.zshrc
- [ ] (automate) screenshots of resulting setup
- [ ] add description to readme
- [ ] auto generate documentation of shortcuts
