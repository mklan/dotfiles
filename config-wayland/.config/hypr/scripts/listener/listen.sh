#!/usr/bin/env bash

function handle {
  if [[ ${1:0:10} == "openwindow" ]]; then
      exec ~/.config/hypr/scripts/listener/handler/openwindow.handler.ts $1 &
  fi
  if [[ ${1:0:11} == "closewindow" ]]; then
      exec ~/.config/hypr/scripts/listener/handler/closewindow.handler.ts $1 &
  fi
  if [[ ${1:0:11} == "workspacev2" ]]; then
      exec ~/.config/hypr/scripts/listener/handler/changeWorkspace.handler.ts $1 &
  fi
}

socat - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done