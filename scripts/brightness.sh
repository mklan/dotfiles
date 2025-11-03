#!/bin/bash

# Function to swap the sign position for brightnessctl
swap_sign_position() {
  local input=$1
  if [[ $input =~ ^([+-])([0-9]+)$ ]]; then
    echo "${BASH_REMATCH[2]}${BASH_REMATCH[1]}"
  else
    echo "Invalid value format. Please use +10 or -10."
    exit 1
  fi
}

# Check if the correct number of arguments are passed
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <value>"
  exit 1
fi

value=$1

# Get the swapped value for brightnessctl

# Get the name of the currently focused monitor
focused_monitor=$(hyprctl monitors -j | jq -r 'first(.[] | select(.focused == true)).name')



# Check if the focused monitor is DP-1
if [[ "$focused_monitor" == "DP-1" || "$focused_monitor" == "DP-2"  ]]; then
  current_brightness=$(ddcutil getvcp 10 --brief | awk '{print $4}')
  sudo ddcutil setvcp 10 $((current_brightness + value))
else
  echo $(swap_sign_position $value)
  brightnessctl set $(swap_sign_position $value)
fi
