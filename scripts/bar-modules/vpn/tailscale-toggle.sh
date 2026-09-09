#!/usr/bin/env bash
# Tailscale VPN toggle — used by the waybar network module and the
# quickshell bar (key icon on hover).
# Privilege escalation is handled by the tailscale-ctl wrapper via
# passwordless sudo (see _patches/tailscale-sudo/tailscale-sudoers).
set -uo pipefail

# tailscale status exit code: 0 = up/connected, non-zero = stopped OR logged out.
# NOTE: never pipe `tailscale status` into a condition with pipefail — it exits 1
# when not connected, which makes the pipeline false even when grep matches.
TS_OUT=$(tailscale status 2>&1 || true)

if tailscale status >/dev/null 2>&1; then
    notify-send "Tailscale" "Bringing Tailscale down…"
    if tailscale-ctl down; then
        notify-send "Tailscale" "Disconnected"
    else
        notify-send -u critical "Tailscale" "Disconnect failed — install _patches/tailscale-sudo/tailscale-sudoers"
    fi
elif [[ "$TS_OUT" == *"Logged out"* ]]; then
    notify-send -u critical "Tailscale" "Not logged in — run 'tailscale-ctl up' in a terminal once to authenticate"
else
    notify-send "Tailscale" "Connecting…"
    if tailscale-ctl up; then
        notify-send "Tailscale" "Connected"
    else
        notify-send -u critical "Tailscale" "Connect failed — install _patches/tailscale-sudo/tailscale-sudoers"
    fi
fi
