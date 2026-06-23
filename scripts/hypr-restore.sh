#!/usr/bin/env bash
# Restore Hyprland workspace from a snapshot produced by hypr-snapshot.sh
# Usage: hypr-restore.sh <snapshot-name-or-path>
set -euo pipefail
SNAP="$1"
if [ -z "$SNAP" ]; then echo "Usage: $0 <snapshot-name-or-path>" >&2; exit 2; fi
# if name provided, look in default dir
OUTDIR="${XDG_DATA_HOME:-$HOME/.local/share}/hypr-snapshots"
if [ -f "$SNAP" ]; then SNAPPATH="$SNAP"; else
  SNAPPATH="$OUTDIR/$SNAP"
  if [ ! -f "$SNAPPATH" ]; then
    # try .json
    SNAPPATH="$OUTDIR/$SNAP.json"
  fi
fi
if [ ! -f "$SNAPPATH" ]; then echo "Snapshot not found: $SNAPPATH" >&2; exit 3; fi
if ! command -v hyprctl >/dev/null 2>&1; then echo "hyprctl required" >&2; exit 4; fi
if ! command -v jq >/dev/null 2>&1; then echo "jq required" >&2; exit 4; fi
TERMINAL=${HYPR_SNAPSHOT_TERMINAL:-alacritty}
# read snapshot
workspace=$(jq -r '.workspace' "$SNAPPATH")
clients=$(jq -c '.clients[]' "$SNAPPATH")
# switch to workspace
echo "Switching to workspace $workspace"
hyprctl dispatch workspace "$workspace" || true
sleep 0.2
# helper to launch a command, trying terminal wrappers if needed
launch_cmd(){
  local cmd="$1"
  local rawexe="$2"
  if [ -z "$cmd" ] || [ "$cmd" = "null" ]; then
    if [ -n "$rawexe" ] && [ "$rawexe" != "null" ]; then
      setsid "$rawexe" >/dev/null 2>&1 &
      return
    fi
    return
  fi
  # if the command looks like a GUI app (no spaces and in PATH) run directly
  local first=$(echo "$cmd" | awk '{print $1}')
  if command -v "$first" >/dev/null 2>&1 && [[ "$cmd" != *" "* ]]; then
    setsid "$cmd" >/dev/null 2>&1 &
    return
  fi
  # otherwise try terminal -e
  case "$TERMINAL" in
    alacritty|kitty|st|urxvt|xterm|foot)
      setsid "$TERMINAL" -e bash -lc "$cmd" >/dev/null 2>&1 &
      ;;
    wezterm)
      setsid wezterm start -- bash -lc "$cmd" >/dev/null 2>&1 &
      ;;
    gnome-terminal)
      setsid gnome-terminal -- bash -lc "$cmd" >/dev/null 2>&1 &
      ;;
    *)
      # fallback: run in background shell (won't have a terminal)
      setsid bash -lc "$cmd" >/dev/null 2>&1 &
      ;;
  esac
}

count=0
for c in $clients; do
  pid=$(echo "$c" | jq -r '.pid // empty')
  exe=$(echo "$c" | jq -r '.exe // .exename // empty')
  rec=$(echo "$c" | jq -r '.recovered_cmd // empty')
  cmdline=$(echo "$c" | jq -r '.cmdline // empty')
  # prefer recovered_cmd, then cmdline, then exe
  if [ -n "$rec" ]; then
    echo "Launching recovered: $rec"
    launch_cmd "$rec" "$exe"
  elif [ -n "$cmdline" ]; then
    echo "Launching cmdline: $cmdline"
    launch_cmd "$cmdline" "$exe"
  elif [ -n "$exe" ]; then
    echo "Launching exe: $exe"
    setsid "$exe" >/dev/null 2>&1 &
  fi
  count=$((count+1))
  sleep 0.2
done

echo "Launched $count clients (they may take a moment to appear)."