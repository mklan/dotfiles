#!/usr/bin/env bash
# dunkler-focus.sh – adjust dimming of the currently focused monitor in Hyprland
#
# Usage: dunkler-focus.sh <delta>
#
# Takes a *delta* (signed integer, e.g. +5 or -5) and adjusts the
# transparency of a dunkler overlay on the currently focused monitor.
#
#   +5  →  brighter  (more transparent, less dimming)
#   -5  →  darker    (more opaque,     more dimming)
#
# Per-monitor state is tracked in a state file so repeated adjustments
# work incrementally across monitor switches.
#
# State file: $XDG_RUNTIME_DIR/dunkler-focus.state  (falls back to /dev/shm)
#
# If the focused monitor appears in DUNKLER_IGNORE, the script does
# *not* invoke dunkler and instead exits with code 42.  The caller can
# detect this and fall back to a different method (e.g. backlight via
# `light`).
#
# Ignore list
# -----------
# Set DUNKLER_IGNORE to a space-separated list of monitor names to
# ignore.  There is NO default – you must opt in explicitly.
#
#   export DUNKLER_IGNORE="eDP-1 DP-2"
#
# Exit codes
# ----------
#   0   dunkler was invoked (or delta was a no-op, e.g. clamped at limit)
#   42  focused monitor is in the ignore list – caller should use fallback
#   1   usage error, missing dependency, or other failure
#
# Hyprland keybind example (~/.config/hypr/hyprland.conf):
#
#   # Dim focused monitor (brightness down / up) with fallback for eDP-1
#   bind = , XF86MonBrightnessDown, exec, sh -c \
#     'DUNKLER_IGNORE=eDP-1 dunkler-focus.sh -5; r=$?; [ $r -eq 42 ] && light -U 5'
#   bind = , XF86MonBrightnessUp, exec, sh -c \
#     'DUNKLER_IGNORE=eDP-1 dunkler-focus.sh +5; r=$?; [ $r -eq 42 ] && light -A 5'
#
# Requirements:
#   - hyprctl (Hyprland)
#   - jq (JSON processor)
#   - dunkler in $PATH

set -euo pipefail

EXIT_IGNORED=42
STATE_FILE="${XDG_RUNTIME_DIR:-/dev/shm}/dunkler-focus.state"
DEFAULT_TRANSPARENCY=100   # 100 = fully transparent = no dimming

usage() {
    echo "Usage: $0 <delta>" >&2
    echo "  delta  signed integer, e.g. +5 (brighter) or -5 (darker)" >&2
    exit 1
}

# ---- argument parsing -----------------------------------------------------
[ $# -eq 1 ] || usage
DELTA="$1"

# Must be a signed integer: optional +/-, then digits
[[ "$DELTA" =~ ^[+-][0-9]+$ ]] || {
    echo "dunkler-focus: error: delta must be a signed integer, e.g. +5 or -5" >&2
    exit 1
}

# ---- dependencies ---------------------------------------------------------
command -v hyprctl >/dev/null 2>&1 || {
    echo "dunkler-focus: error: hyprctl not found – this script requires Hyprland" >&2
    exit 1
}
command -v jq >/dev/null 2>&1 || {
    echo "dunkler-focus: error: jq not found" >&2
    exit 1
}
command -v dunkler >/dev/null 2>&1 || {
    echo "dunkler-focus: error: dunkler not found in PATH" >&2
    exit 1
}

# ---- determine focused monitor --------------------------------------------
# hyprctl monitors -j returns an array of monitor objects; the "focused"
# field indicates where the active workspace lives.
MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

if [ -z "$MONITOR" ]; then
    echo "dunkler-focus: error: could not determine focused monitor" >&2
    exit 1
fi

# ---- ignore list ----------------------------------------------------------
# No default – the caller must set DUNKLER_IGNORE explicitly if they want
# certain monitors to be skipped.
if [ -n "${DUNKLER_IGNORE:-}" ]; then
    for ignored in $DUNKLER_IGNORE; do
        if [ "$MONITOR" = "$ignored" ]; then
            echo "dunkler-focus: monitor '$MONITOR' is ignored" >&2
            exit $EXIT_IGNORED
        fi
    done
fi

# ---- state retrieval ------------------------------------------------------
mkdir -p "$(dirname "$STATE_FILE")"

current="$DEFAULT_TRANSPARENCY"

if [ -f "$STATE_FILE" ]; then
    while IFS='=' read -r mon val; do
        if [ "$mon" = "$MONITOR" ]; then
            current="$val"
            break
        fi
    done < "$STATE_FILE"
fi

# Sanity-check the stored value (guard against corruption)
[[ "$current" =~ ^[0-9]+$ ]] && [ "$current" -le 100 ] || current="$DEFAULT_TRANSPARENCY"

# ---- compute new transparency ---------------------------------------------
new=$(( current + DELTA ))

# Clamp to 0–100
[ "$new" -lt 0 ]   && new=0
[ "$new" -gt 100 ] && new=100

# No change (already at limit)?  Skip dunkler restart.
if [ "$new" -eq "$current" ]; then
    exit 0
fi

# ---- persist state --------------------------------------------------------
# Rewrite the state file, keeping other monitors' entries intact.
{
    if [ -f "$STATE_FILE" ]; then
        while IFS='=' read -r mon val; do
            if [ -n "$mon" ] && [ "$mon" != "$MONITOR" ]; then
                printf '%s=%s\n' "$mon" "$val"
            fi
        done < "$STATE_FILE"
    fi
    printf '%s=%s\n' "$MONITOR" "$new"
} > "${STATE_FILE}.tmp"

mv "${STATE_FILE}.tmp" "$STATE_FILE"

# ---- apply ----------------------------------------------------------------
exec dunkler -m "$MONITOR" "$new"
