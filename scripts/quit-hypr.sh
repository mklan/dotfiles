#!/usr/bin/env bash
# Log out of the Hyprland session (back to the TTY).
#
# Hyprland 0.56 with the lua config provider: dispatchers are lua expressions,
# so the shutdown request is 'hl.dsp.exit()' — the old `hyprctl dispatch exit 0`
# silently fails and Hyprland never exits.
#
# Careful with the fallback: the start-hyprland watchdog restarts Hyprland
# whenever the compositor dies uncleanly, and the restarted instance comes back
# in safe mode (i.e. without the config). So ask for a clean shutdown first and
# give it time; only kill as a very last resort — and stop the watchdog first so
# nothing respawns Hyprland.

if ! pgrep -x Hyprland >/dev/null; then
    exit 0
fi

# Ask Hyprland to shut down cleanly (exit status 0 -> the watchdog exits too).
hyprctl dispatch 'hl.dsp.exit()' >/dev/null 2>&1

# Wait up to 10s for Hyprland to shut down on its own.
for _ in $(seq 1 100); do
    pgrep -x Hyprland >/dev/null || exit 0
    sleep 0.1
done

# Hyprland ignored the exit request. Take the watchdog down first so it cannot
# respawn Hyprland in safe mode, then terminate the compositor.
pkill -x start-hyprland 2>/dev/null
sleep 0.5

killall -TERM Hyprland 2>/dev/null
for _ in $(seq 1 20); do
    pgrep -x Hyprland >/dev/null || exit 0
    sleep 0.1
done

killall -9 Hyprland 2>/dev/null
