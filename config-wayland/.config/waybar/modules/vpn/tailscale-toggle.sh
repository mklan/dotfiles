#!/usr/bin/env bash
# Waybar on-click handler for Tailscale VPN toggle
# Uses pkexec for fingerprint auth when elevated privileges are needed
set -euo pipefail

# Check if tailscaled is running
if systemctl is-active --quiet tailscaled 2>/dev/null; then
    # Toggle: if up, bring down
    if tailscale status 2>/dev/null | grep -qv "stopped"; then
        notify-send "Tailscale" "Bringing Tailscale down…"
        tailscale-ctl down
        notify-send "Tailscale" "Disconnected"
    else
        # tailscaled running but Tailscale stopped — bring up
        notify-send "Tailscale" "Connecting…"
        tailscale-ctl up
        notify-send "Tailscale" "Connected"
    fi
else
    # tailscaled not running — need sudo to start it
    notify-send "Tailscale" "Starting Tailscale… (authenticate with fingerprint)"
    if pkexec systemctl start tailscaled; then
        sleep 1
        tailscale-ctl up
        notify-send "Tailscale" "Connected"
    else
        notify-send -u critical "Tailscale" "Failed to start tailscaled"
    fi
fi
