#!/usr/bin/env bash

function handle {
  echo $1
  case $1 in
    'fullscreen>>1') ~/.config/hypr/scripts/hyproled.sh off ;;
    'fullscreen>>0') ~/.config/hypr/scripts/hyproled.sh -a 0:0:2880:45 ;;
    #'openlayer>>rofi') ~/.config/hypr/scripts/hyproled.sh -i 0:0:3000:45 ;; 
    #'closelayer>>rofi') ~/.config/hypr/scripts/hyproled.sh 0:0:3000:45 ;;
    
    # openwindow*) exec ~/.config/hypr/scripts/listener/handler/openwindow.handler.ts $1 & ;;
    # closewindow*) exec ~/.config/hypr/scripts/listener/handler/closewindow.handler.ts $1 & ;;
    # workspacev2*) exec ~/.config/hypr/scripts/listener/handler/changeWorkspace.handler.ts $1 & ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done