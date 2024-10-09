#!/bin/bash

weather=$(curl -s "wttr.in/$1?format=%t")

# Remove the + sign for positive temperatures
temp=$(echo $weather | sed 's/+//')

# Fetch the weather condition to determine the icon
condition=$(curl -s "wttr.in/$1?format=%C")

case $condition in
  *Sunny*|*Clear*)
    icon="" # ""  # Font Awesome sun icon
    ;;
  *"Partly cloudy"*|*Cloudy*|*Overcast*)
    icon=""  #""  # Font Awesome cloud icon
    ;;
  *Rain*|*Drizzle*)
    icon="󰖗"  # Font Awesome umbrella icon
    ;;
  *Snow*)
    icon="󰼶"  # Font Awesome snowflake icon
    ;;
  *)
    icon=""
    ;;
esac

# Output for Waybar
echo "{\"text\": \"${icon} ${temp}\", \"tooltip\": \"${condition}\"}"