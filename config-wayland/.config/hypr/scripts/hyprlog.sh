#!/bin/bash
# hyprlog.sh - show hyprland log for the last N minutes
# Usage: hyprlog.sh [minutes] [--all]
#   minutes  : how many minutes back to show (default: 10)
#   --all    : show all log levels, not just errors/warnings/config

MINUTES="${1:-10}"
SHOW_ALL="${2:-}"

# resolve log file via hyprctl or fallback to env var
if command -v hyprctl &>/dev/null; then
  SIG=$(hyprctl instancesignatures 2>/dev/null | awk '/^instance /{print $2}' | tr -d ':' | head -1)
fi
SIG="${SIG:-$HYPRLAND_INSTANCE_SIGNATURE}"
LOGFILE="/run/user/${UID}/hypr/${SIG}/hyprland.log"

if [[ ! -f "$LOGFILE" ]]; then
  echo "Error: log file not found: $LOGFILE" >&2
  exit 1
fi

# estimate how many lines correspond to $MINUTES by comparing
# hyprland's start time (encoded in the instance signature timestamp) to now
START_TS=$(echo "$SIG" | cut -d_ -f2)
NOW_TS=$(date +%s)
RUNTIME_MINS=$(( (NOW_TS - START_TS) / 60 ))
RUNTIME_MINS=$(( RUNTIME_MINS < 1 ? 1 : RUNTIME_MINS ))

TOTAL_LINES=$(wc -l < "$LOGFILE")
TAIL_LINES=$(( TOTAL_LINES * MINUTES / RUNTIME_MINS ))
TAIL_LINES=$(( TAIL_LINES < 1 ? 1 : TAIL_LINES ))
TAIL_LINES=$(( TAIL_LINES > TOTAL_LINES ? TOTAL_LINES : TAIL_LINES ))

echo "==> Hyprland log — last ~${MINUTES} min (last ${TAIL_LINES}/${TOTAL_LINES} lines)" >&2
echo "==> Log: $LOGFILE" >&2
echo "" >&2

if [[ "$SHOW_ALL" == "--all" ]]; then
  tail -n "$TAIL_LINES" "$LOGFILE"
else
  # focus on errors, warnings, and config-related lines; colorise if terminal
  tail -n "$TAIL_LINES" "$LOGFILE" \
    | grep --color=never -iE \
        '^\s*(ERR|WARN|LOG)\s*(\[.*\])?\s*]:|config|parse|error|warning|unknown|invalid|missing|deprecated|cannot|failed|couldn'\''t' \
    | grep -v '^\s*DEBUG' \
    | GREP_COLOR='01;31' grep --color=auto -iE 'ERR|error|failed|cannot|invalid|unknown|missing|couldn'\''t|$' \
    | GREP_COLOR='01;33' grep --color=auto -iE 'WARN|warning|deprecated|$'
fi
