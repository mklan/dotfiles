#!/usr/bin/env bash

# Hyprland "docked mode" toggle.
#
# When active:
#   - closing the laptop lid will NOT suspend the system,
#   - the internal display (eDP-1) is disabled while an external monitor is connected,
#   - opening the lid or disconnecting the external monitor restores the normal layout.
#
# Usage: docked-mode.sh [--on|--off|--toggle|--status]
# No persistent state file is used; the daemon process itself represents the active state.

set -euo pipefail

SCRIPT_PATH=$(realpath "$0")
PIDFILE="${XDG_RUNTIME_DIR:-/run/user/$(id - u)}/hypr-docked-mode.pid"

INTERNAL_MONITOR="eDP-1"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

find_lid_state_file() {
    local f
    for f in /proc/acpi/button/lid/*/state; do
        if [[ -f "$f" ]]; then
            printf '%s\n' "$f"
            return 0
        fi
    done
    return 1
}

is_lid_closed() {
    local lid_file
    lid_file=$(find_lid_state_file) || return 1
    grep -qi "closed" "$lid_file"
}

has_external_monitor() {
    local monitors
    monitors=$(hyprctl monitors 2>/dev/null | awk '/^Monitor / {print $2}' | grep -v "^${INTERNAL_MONITOR}$") || true
    [[ -n "$monitors" ]]
}

apply_docked() {
    # Disable the internal laptop display; Hyprland moves its workspaces to the
    # external monitor(s) automatically.
    hyprctl keyword monitor "${INTERNAL_MONITOR},disable" >/dev/null 2>&1
}

apply_normal() {
    # Reload Hyprland config to restore the original monitor layout from monitors.conf.
    hyprctl reload >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# Daemon
# ------------------------------------------------------------------------------

daemon_inner() {
    local last_state=""

    update_state() {
        if is_lid_closed && has_external_monitor; then
            if [[ "$last_state" != "docked" ]]; then
                apply_docked
                last_state="docked"
            fi
        else
            if [[ "$last_state" != "normal" ]]; then
                apply_normal
                last_state="normal"
            fi
        fi
    }

    # Make sure we always try to restore the normal layout on exit.
    trap 'apply_normal' EXIT INT TERM

    while true; do
        update_state
        sleep 1
    done
}

# ------------------------------------------------------------------------------
# Control
# ------------------------------------------------------------------------------

is_running() {
    if [[ -f "$PIDFILE" ]]; then
        local pid
        pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

start() {
    if is_running; then
        echo "Docked mode is already active" >&2
        return 1
    fi

    mkdir -p "$(dirname "$PIDFILE")"

    # Wrap the daemon in systemd-inhibit so logind does NOT suspend when the
    # lid is closed while docked mode is active.
    nohup systemd-inhibit \
        --what=handle-lid-switch \
        --why="Hyprland docked mode" \
        --mode=block \
        "$SCRIPT_PATH" --daemon-inner \
        >/dev/null 2>&1 &

    echo $! > "$PIDFILE"
    echo "Docked mode enabled"
}

stop() {
    local pid=""
    if [[ -f "$PIDFILE" ]]; then
        pid=$(cat "$PIDFILE")
        rm -f "$PIDFILE"
    fi

    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null || true
    fi

    # Fallback cleanup in case the PID file was stale.
    pkill -f "${SCRIPT_PATH} --daemon-inner" 2>/dev/null || true

    apply_normal
    echo "Docked mode disabled"
}

toggle() {
    if is_running; then
        stop
    else
        start
    fi
}

status() {
    if is_running; then
        echo "on"
    else
        echo "off"
    fi
}

# ------------------------------------------------------------------------------
# CLI
# ------------------------------------------------------------------------------

case "${1:-toggle}" in
    --on|on|start)
        start
        ;;
    --off|off|stop)
        stop
        ;;
    --toggle|toggle|"")
        toggle
        ;;
    --status|status)
        status
        ;;
    --daemon-inner)
        daemon_inner
        ;;
    *)
        echo "Usage: $(basename "$0") [--on|--off|--toggle|--status]" >&2
        exit 1
        ;;
esac
