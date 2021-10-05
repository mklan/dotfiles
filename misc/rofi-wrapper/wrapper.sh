#!/usr/bin/env bash

function drun()
{
  rofi -config $HOME/.config/rofi/dark.rasi \
    -show-icons \
    -columns 3 \
    -modi drun \
    -show drun \
    -display-drun '' \
    -p '->'
}

function run()
{
  rofi \
    -config $HOME/.config/rofi/dark.rasi \
    -modi run \
    -show run \
    -display-run "" \
    -p '->'
}

function dmenu()
{
  rofi \
    -config $HOME/.config/rofi/dark.rasi \
    -theme-str 'listview { enabled: false;}' \
    -p '' \
    -dmenu
}

function main()
{
  case "$@" in
    "--drun")
      drun;;
    "--run")
      run;;
    "--dmenu")
      dmenu;;
  esac
}

main "$@"

