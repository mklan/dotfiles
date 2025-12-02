#!/bin/bash

API_KEY=$OPENWEATHERMAP_KEY  # <-- Replace with your actual API key
UNITS="metric"                         # Use "imperial" for Fahrenheit

# If no city is given, try to detect it via IP geolocation
if [ -z "$1" ]; then
  CITY=$(curl -s ipinfo.io/city)
else
  CITY="$1"
fi

response=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=${UNITS}")

temp=$(echo "$response" | jq '.main.temp' | xargs printf "%.0f") # Round to integer
condition=$(echo "$response" | jq -r '.weather[0].main')

# Choose icon based on condition
case $condition in
  Clear)
    icon=""
    ;;
  Clouds)
    icon=""
    ;;
  Rain|Drizzle)
    icon="󰖗"
    ;;
  Snow)
    icon="󰼶"
    ;;
  *)
    icon=""
    ;;
esac

# Output for Waybar
echo "{\"text\": \" ${icon}  ${temp}°C\", \"tooltip\": \"${condition} in ${CITY}\"}"