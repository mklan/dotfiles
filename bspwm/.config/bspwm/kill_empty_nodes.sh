#!/bin/bash
#
# Matthias Klan 2020
#
# Kills broken empty nodes
#
bspc query -N -n .window | while read node ; do
	if [[ $(xtitle $node) == "" ]]; then
	   echo "kill broken empty node $node"
	   notify-send "kill broken empty node $node"
	   bspc node $node -k	
	fi
done
