#! /bin/sh
#in sxhkdrc call it with
#alt + {1-9,0}
#     summonworkspace.sh {1-9,10}
  D=$(bspc query -D -m | sed -n "$@ p"); \
  M=$(bspc query --monitors --desktop $@); \
  if [ $(bspc query --desktops --monitor $M | wc -l) -gt 1 ]; then \
    if [ $(bspc query --desktops --desktop focused) != $D ]; then \
      bspc desktop $@ --to-monitor focused; \
      bspc desktop $@ --focus; \
    fi; \
  elif [ $(bspc query --monitors --monitor focused) != $M ]; then \
    bspc desktop $(bspc query --monitors --desktop $@):focused --swap $(bspc query -M -m focused):focused; \
    #bspc desktop DVI-0:focused –swap DVI-1:focused; 
  fi
