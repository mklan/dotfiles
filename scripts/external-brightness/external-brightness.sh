#!/usr/bin/env bash
#
# external-brightness.sh — control an external monitor's brightness via DDC/CI
#
# Uses ddcutil (VCP code 0x10 = brightness). See readme.md for setup.

set -euo pipefail

DDCUTIL="$(command -v ddcutil || true)"
VCP_CODE=10                     # 0x10 = brightness
DISPLAY_NUM=""                  # empty = display 1 (first DDC-capable)
STEP=5                          # default increment for up/down

# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

err() { printf 'error: %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'EOF'
Usage: external-brightness.sh [options] <command> [value]

Control the brightness of an external monitor over DDC/CI (ddcutil).

Commands:
  get            Print current brightness (0-100)
  set <value>    Set brightness to <value> (0-100)
  set +N / -N    Relative change
  up             Increase brightness by --step (default 5)
  down           Decrease brightness by --step (default 5)
  max            Set brightness to 100
  min            Set brightness to 1
  list           List DDC/CI-capable displays

Options:
  -d, --display N   Target display N (see: list). Default: 1 (first DDC-capable).
  -s, --step N      Step size for up/down (default 5)
  -h, --help        Show this help

Setup (one-time, see readme.md):
  yay -S ddcutil
  sudo modprobe i2c-dev
  sudo ddcutil detect
EOF
}

# Build the --display argument for ddcutil. Always targeting a specific
# display avoids ddcutil scanning every I2C bus (which is very slow).
display_args() {
    printf '%s' "--display ${DISPLAY_NUM:-1}"
}

# Run ddcutil, preferring the current user. Escalate to sudo only on
# permission errors, and retry transient DDC/CI I2C glitches.
ddc() {
    local args output rc errfile errmsg try
    args=("$DDCUTIL" $(display_args) "$@")

    for try in 1 2 3; do
        errfile="$(mktemp)"
        output="$("${args[@]}" 2>"$errfile")"
        rc=$?
        errmsg="$(<"$errfile")"
        rm -f "$errfile"

        [[ $rc -eq 0 ]] && { printf '%s\n' "$output"; return 0; }

        # Permission problem -> escalate to sudo and return its result.
        if [[ "$errmsg" =~ [Pp]ermission|[Aa]ccess[[:space:]]+denied|EACCES|denied ]]; then
            sudo "${args[@]}" 2>/dev/null
            return
        fi

        # Otherwise assume a transient DDC/CI glitch; pause and retry.
        sleep 0.2
    done

    printf '%s\n' "$errmsg" >&2
    return "$rc"
}

# Print current brightness (0-100).
get_brightness() {
    ddc getvcp "$VCP_CODE" --brief | awk 'NR == 1 { print $4 }'
}

# Set brightness. VALUE may be absolute (50) or relative with a leading
# sign (+5 / -5). ddcutil clamps at 0 and max natively, so a single
# setvcp call is enough for up/down/set.
set_brightness() {
    local value="$1" sign="" amount=""
    case "$value" in
        +*) sign="+"; amount="${value#+}" ;;
        -*) sign="-"; amount="${value#-}" ;;
        *)  sign="";  amount="$value" ;;
    esac
    if [[ -n "$sign" ]]; then
        ddc setvcp "$VCP_CODE" "$sign" "$amount" >/dev/null || err "could not set brightness"
    else
        ddc setvcp "$VCP_CODE" "$amount" >/dev/null || err "could not set brightness"
    fi
}

list_displays() {
    ddcutil detect 2>/dev/null | awk '
        /^Display [0-9]+/  { disp=$2; model=""; conn=""; next }
        disp != "" && /DRM_connector:/ { sub(/^[[:space:]]*DRM_connector:[[:space:]]*/, ""); conn=$0 }
        disp != "" && /Model:/        { sub(/^[[:space:]]*Model:[[:space:]]*/, ""); model=$0; printf "Display %s  %s  (%s)\n", disp, model, conn; disp="" }
    '
}

# ---------------------------------------------------------------------------
# arg parsing
# ---------------------------------------------------------------------------

[[ -n "$DDCUTIL" ]] || err "ddcutil not found — install with: yay -S ddcutil"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--display) DISPLAY_NUM="${2:?missing value for $1}"; shift 2 ;;
        -s|--step)    STEP="${2:?missing value for $1}"; shift 2 ;;
        -h|--help)    usage; exit 0 ;;
        -*)           err "unknown option: $1" ;;
        *)            break ;;
    esac
done

[[ "$STEP" =~ ^[0-9]+$ ]] || err "step must be a positive integer"
COMMAND="${1:-}"
VALUE="${2:-}"

# ---------------------------------------------------------------------------
# commands
# ---------------------------------------------------------------------------

case "$COMMAND" in
    get)
        get_brightness
        ;;

    list)
        list_displays
        ;;

    max)
        set_brightness 100
        ;;

    min)
        set_brightness 1
        ;;

    set)
        [[ -n "$VALUE" ]] || err "usage: $0 set <0-100>"
        [[ "$VALUE" =~ ^[+-]?[0-9]+$ ]] || err "value must be an integer"
        set_brightness "$VALUE"
        ;;

    up)
        set_brightness "+$STEP"
        ;;

    down)
        set_brightness "-$STEP"
        ;;

    "")
        usage
        exit 1
        ;;

    *)
        err "unknown command: $COMMAND"
        ;;
esac
