#!/bin/bash

# Check if the scale argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <scale>"
  echo "Example: $0 3       # Set scale to 3"
  echo "Example: $0 +0.5    # Increase scale by 0.5"
  echo "Example: $0 -0.2    # Decrease scale by 0.2"
  exit 1
fi

# Get the scale argument
scale_arg=$1

# Path to the monitor configuration file
config_file="$HOME/.config/hypr/conf/monitors.conf"

# Check if the config file exists
if [ ! -f "$config_file" ]; then
  echo "Monitor configuration file not found: $config_file"
  exit 1
fi

# Get the active monitor
# Get the active monitor and its details using JSON output and jq
monitor_info=$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | {name: .name, scale: .scale}')

# Extract monitor details
active_monitor=$(echo "$monitor_info" | jq -r '.name')

# Check if the active monitor was found
if [ -z "$active_monitor" ]; then
  echo "No active monitor found!"
  exit 1
fi

# Find the active monitor's configuration in the config file
monitor_config=$(grep -E "^monitor=$active_monitor," "$config_file")
# Check if the active monitor was found
if [ -z "$active_monitor" ]; then
  echo "No active monitor found!"
  exit 1
fi

# Find the active monitor's configuration in the config file
monitor_config=$(grep -E "^monitor=$active_monitor," "$config_file")

# Check if the monitor configuration was found
if [ -z "$monitor_config" ]; then
  echo "No configuration found for monitor $active_monitor in $config_file!"
  exit 1
fi

# Extract the current scale from the monitor configuration
current_scale=$(echo "$monitor_config" | awk -F',' '{print $4}')

# Check if the current scale was found
if [ -z "$current_scale" ]; then
  echo "Could not determine the current scale of monitor $active_monitor!"
  exit 1
fi

# Determine if the argument is relative or absolute
if [[ $scale_arg == +* ]]; then
  # Relative increase
  new_scale=$(echo "$current_scale + ${scale_arg#+}" | bc)
elif [[ $scale_arg == -* ]]; then
  # Relative decrease
  new_scale=$(echo "$current_scale - ${scale_arg#-}" | bc)
else
  # Absolute scale
  new_scale=$scale_arg
fi

# Extract the monitor's resolution, refresh rate, and positioning from the config
resolution=$(echo "$monitor_config" | awk -F',' '{print $2}')
positioning=$(echo "$monitor_config" | awk -F',' '{print $3}')

# Construct the new monitor configuration for hyprctl
new_monitor_config="$active_monitor,$resolution,$positioning,$new_scale"

# Update the monitor scale using hyprctl
hyprctl keyword monitor "$new_monitor_config"

echo "Scale of monitor $active_monitor changed from $current_scale to $new_scale."
echo "New monitor configuration: $new_monitor_config"