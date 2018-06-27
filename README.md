# .dotfiles

Configuration of my arch system running xfce4 as desktop manager and i3 as window manager 

> __Warning!__ This repository is currently in an early pre-alpha state. The configuration is not easy to setup, due to the many packages which must be installed.

## Utilized packages / applications / tools

> __Warning!__ The list ist not complete!

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

After that run `./install.sh`.

Finally, install all the missing packages which are not defined in the script yet.

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
