#!/usr/bin/env bash
#
# brightness.sh — unified brightness control for Hyprland.
#
# Routes the request to the monitor currently under the mouse cursor:
#   - external monitors (DDC/CI)  -> external-brightness/external-brightness.sh
#   - laptop panel (backlight)     -> brightnessctl
#
# Usage:
#   brightness.sh [options] <command> [value]
#
# Commands:
#   get            Print current brightness (0-100)
#   set <0-100>    Set absolute brightness
#   set +N / -N    Relative change
#   up / down      Step by --step (default 5)
#   max / min      Set 100 / 1
#   status         Show which target is active and its brightness
#   list           Show external (DDC) displays and the laptop device
#
# Options:
#   -s, --step N              Step size for up/down (default 5)
#   -f, --force <mode>        Override auto-detection: 'external' or 'laptop'
#   -d, --display N           External display number for --force external
#   -h, --help                Show this help
#
# Environment:
#   BRIGHTNESS_DEVICE         brightnessctl backlight device (auto-detected)

set -euo pipefail

STEP=5
FORCE=""
DISPLAY_NUM=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTERNAL="$SCRIPT_DIR/external-brightness/external-brightness.sh"
LAPTOP_DEV="${BRIGHTNESS_DEVICE:-}"

err() { printf 'error: %s\n' "$*" >&2; exit 1; }

usage() {
    sed -n '2,28p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
}

# ---------------------------------------------------------------------------
# monitor detection
# ---------------------------------------------------------------------------

# Name of the monitor whose area contains the cursor (Hyprland global coords).
cursor_monitor() {
    local cx cy
    read -r cx cy <<<"$(hyprctl cursorpos | tr -d ',')"
    hyprctl monitors -j | jq -r --argjson cx "$cx" --argjson cy "$cy" '
        .[] | select(.disabled != true) |
        (.width  / .scale) as $w | (.height / .scale) as $h |
        (.transform == 1 or .transform == 3 or .transform == 4 or .transform == 6) as $swapped |
        (if $swapped then $h else $w end) as $lw |
        (if $swapped then $w else $h end) as $lh |
        select($cx >= .x and $cx < (.x + $lw) and $cy >= .y and $cy < (.y + $lh)) |
        .name'
}

focused_monitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name' | head -1
}

# Map external monitor connector names -> ddcutil display numbers.
# Output: one "connector displaynum" pair per line (e.g. "DP-1 1").
external_map() {
    ddcutil detect 2>/dev/null | awk '
        /^Display [0-9]+/ { disp = $2; next }
        disp != "" && /DRM_connector:/ {
            conn = $0
            sub(/^[[:space:]]*DRM_connector:[[:space:]]*/, "", conn)
            sub(/^card[0-9]+-/, "", conn)     # card1-DP-1 -> DP-1
            print conn, disp
            disp = ""
        }'
}

# `ddcutil detect` scans every I2C bus and is slow (~7s), so cache its result.
# The cache is keyed on the set of connected monitor names and refreshed only
# when that changes (hotplug) or explicitly via `list`.
CACHE_FILE="${XDG_RUNTIME_DIR:-/tmp}/brightness-external-map.cache"

monitor_sig() {
    hyprctl monitors -j | jq -r '[.[] | select(.disabled != true) | .name] | sort | join(" ")'
}

load_external_map() {
    local sig cached_sig refresh="${1:-}"
    sig="$(monitor_sig)"

    if [[ "$refresh" != "refresh" && -f "$CACHE_FILE" ]]; then
        cached_sig="$(sed -n 's/^#sig: //p' "$CACHE_FILE" | head -1)"
        if [[ "$cached_sig" == "$sig" ]]; then
            EXT=()
            while read -r conn disp; do
                [[ -n "$conn" && -n "$disp" ]] && EXT["$conn"]="$disp"
            done < <(grep -v '^#' "$CACHE_FILE")
            return
        fi
    fi

    external_map > "$CACHE_FILE.tmp"
    { printf '#sig: %s\n' "$sig"; cat "$CACHE_FILE.tmp"; } > "$CACHE_FILE"
    rm -f "$CACHE_FILE.tmp"

    EXT=()
    while read -r conn disp; do
        [[ -n "$conn" && -n "$disp" ]] && EXT["$conn"]="$disp"
    done < <(grep -v '^#' "$CACHE_FILE")
}

# ---------------------------------------------------------------------------
# laptop backlight helpers
# ---------------------------------------------------------------------------

detect_laptop_device() {
    # `brightnessctl -l` lines look like: Device 'amdgpu_bl1' of class 'backlight':
    brightnessctl -l 2>/dev/null | awk -F"'" '$4 == "backlight" { print $2; exit }'
}

laptop_get_pct() {
    brightnessctl -m -d "$LAPTOP_DEV" | awk -F, '{ gsub(/%/, "", $4); print $4 }'
}

# ---------------------------------------------------------------------------
# argument parsing
# ---------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--step)    STEP="${2:?missing value for $1}"; shift 2 ;;
        -f|--force)   FORCE="${2:?missing value for $1}"; shift 2 ;;
        -d|--display) DISPLAY_NUM="${2:?missing value for $1}"; shift 2 ;;
        -h|--help)    usage ;;
        -*)           err "unknown option: $1" ;;
        *)            break ;;
    esac
done

[[ "$STEP" =~ ^[0-9]+$ ]] || err "step must be a positive integer"
CMD="${1:-}"
VALUE="${2:-}"

# ---------------------------------------------------------------------------
# resolve target
# ---------------------------------------------------------------------------

declare -A EXT

if [[ -n "$FORCE" ]]; then
    case "$FORCE" in
        external)
            TARGET="external"
            load_external_map
            if [[ -z "$DISPLAY_NUM" ]]; then
                fm="$(focused_monitor || true)"
                if [[ -n "${EXT[$fm]:-}" ]]; then
                    MONITOR="$fm"; DISPLAY_NUM="${EXT[$fm]}"
                else
                    MONITOR="$(printf '%s\n' "${!EXT[@]}" | sort | head -1)"
                    [[ -n "$MONITOR" ]] && DISPLAY_NUM="${EXT[$MONITOR]}"
                fi
            fi
            [[ -n "$DISPLAY_NUM" ]] || err "no external (DDC/CI) display detected"
            ;;
        laptop) TARGET="laptop"; MONITOR="" ;;
        *) err "invalid --force mode: $FORCE (use 'external' or 'laptop')" ;;
    esac
else
    MONITOR="$(cursor_monitor || true)"
    [[ -z "$MONITOR" ]] && MONITOR="$(focused_monitor || true)"

    # Fast path: embedded DisplayPort is always the internal laptop panel,
    # so we can skip the (slow) ddcutil detection entirely.
    if [[ "$MONITOR" == eDP-* ]]; then
        TARGET="laptop"
    else
        load_external_map
        if [[ -n "${EXT[$MONITOR]:-}" ]]; then
            TARGET="external"
            DISPLAY_NUM="${EXT[$MONITOR]}"
        else
            TARGET="laptop"
        fi
    fi
fi

[[ -n "$LAPTOP_DEV" ]] || LAPTOP_DEV="$(detect_laptop_device)"
[[ -n "$LAPTOP_DEV" ]] || err "no backlight device found for brightnessctl"

# ---------------------------------------------------------------------------
# command dispatch
# ---------------------------------------------------------------------------

do_get() {
    if [[ "$TARGET" == external ]]; then
        "$EXTERNAL" -d "$DISPLAY_NUM" get
    else
        laptop_get_pct
    fi
}

do_set() {
    local v="$1"
    if [[ "$TARGET" == external ]]; then
        "$EXTERNAL" -d "$DISPLAY_NUM" set "$v" >/dev/null
    elif [[ "$v" == +* ]]; then
        brightnessctl -q -d "$LAPTOP_DEV" set "+${v#+}%"
    elif [[ "$v" == -* ]]; then
        brightnessctl -q -d "$LAPTOP_DEV" set "${v#-}%-"
    else
        brightnessctl -q -d "$LAPTOP_DEV" set "${v}%"
    fi
}

do_status() {
    if [[ "$TARGET" == external ]]; then
        printf 'external  %s (ddcutil display %s): %s%%\n' \
            "$MONITOR" "$DISPLAY_NUM" "$("$EXTERNAL" -d "$DISPLAY_NUM" get)"
    else
        printf 'laptop    %s (%s): %s%%\n' \
            "${MONITOR:-built-in}" "$LAPTOP_DEV" "$(laptop_get_pct)"
    fi
}

do_list() {
    printf 'External (DDC/CI) displays:\n'
    if [[ ${#EXT[@]} -eq 0 ]]; then
        printf '  (none detected)\n'
    else
        for conn in "${!EXT[@]}"; do
            printf '  %-12s display %s\n' "$conn" "${EXT[$conn]}"
        done | sort
    fi
    printf 'Laptop backlight:\n'
    printf '  %s\n' "$LAPTOP_DEV"
}

case "$CMD" in
    get)    do_get ;;
    set)
        [[ -n "$VALUE" ]] || err "usage: $0 set <0-100>"
        [[ "$VALUE" =~ ^[+-]?[0-9]+$ ]] || err "value must be an integer"
        do_set "$VALUE"
        ;;
    up)     do_set "+$STEP" ;;
    down)   do_set "-$STEP" ;;
    max)    do_set 100 ;;
    min)    do_set 1 ;;
    status) do_status ;;
    list)   load_external_map refresh; do_list ;;
    "")     usage ;;
    *)      err "unknown command: $CMD" ;;
esac

