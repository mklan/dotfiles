#!/bin/bash

# OpenWeatherMap API key — read from environment variable.
# Waybar doesn't inherit shell env vars; see scripts/bar-modules/weather/SETUP.md
# for how to configure this securely.
API_KEY="${OPENWEATHER_API_KEY:-}"
if [ -z "$API_KEY" ]; then
    echo '{"text": " 󰅐 ?", "tooltip": "OPENWEATHER_API_KEY is not set"}'
    exit 1
fi
UNITS="metric"
CITY="${1:-}"

# ── Helper: fetch with timeout, fail silently ──
fetch_url() {
    curl -sf --connect-timeout 5 --max-time 10 "$1" 2>/dev/null
}

# ── Get city ──
if [ -z "$CITY" ]; then
    CITY=$(fetch_url "ipinfo.io/city")
    [ -z "$CITY" ] && CITY="Frankfurt am Main"
fi

# ── Fetch weather ──
WEATHER_URL="https://api.openweathermap.org/data/2.5/weather?q=$(echo "$CITY" | sed 's/ /%20/g')&appid=${API_KEY}&units=${UNITS}"
RESPONSE=$(fetch_url "$WEATHER_URL")

# ── Parse ──
TEMP=""
CONDITION=""
if [ -n "$RESPONSE" ]; then
    COD=$(echo "$RESPONSE" | jq -r '.cod' 2>/dev/null)
    if [ "$COD" = "200" ]; then
        TEMP=$(echo "$RESPONSE" | jq -r '.main.temp' 2>/dev/null)
        CONDITION=$(echo "$RESPONSE" | jq -r '.weather[0].main' 2>/dev/null)
    fi
fi

# ── Choose icon + output ──
if [ -n "$TEMP" ] && [ "$TEMP" != "null" ]; then
    case $CONDITION in
        Clear)               ICON="☀" ;;
        Clouds)              ICON="" ;;
        Rain|Drizzle)        ICON="󰖗" ;;
        Thunderstorm)        ICON="󰙾" ;;
        Snow)                ICON="󰼶" ;;
        Mist|Fog|Haze|Smoke) ICON="󰖑" ;;
        *)                   ICON="" ;;
    esac
    TEMP=$(printf "%.0f" "$TEMP" 2>/dev/null || echo "?")
    echo "{\"text\": \" ${ICON} ${TEMP}°C\", \"tooltip\": \"${CONDITION} in ${CITY}\"}"
else
    echo "{\"text\": \" 󰅐 ?\", \"tooltip\": \"Weather unavailable\"}"
fi