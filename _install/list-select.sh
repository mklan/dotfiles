#!/bin/bash

list=$(sed -e '/^#/d' $1) # trim comments
#TODO sort

# preselect all
options=()
for entry in $list
do
  options+=("$entry" "some comment" "on")
done

cmd=(dialog --separate-output --checklist "${2:-Select options:}" 22 76 16)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
echo $choices