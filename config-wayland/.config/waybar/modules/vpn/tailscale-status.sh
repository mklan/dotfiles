#!/usr/bin/env bash
# Waybar module: displays Tailscale VPN status with color
# Outputs JSON with class and tooltip

STATUS="down"

# Check if tailscaled is running and Tailscale is up
if systemctl is-active --quiet tailscaled 2>/dev/null; then
    OUTPUT=$(tailscale status 2>/dev/null || true)
    if echo "$OUTPUT" | grep -q "Tailscale is stopped"; then
        STATUS="stopped"
    elif [ -n "$OUTPUT" ]; then
        STATUS="up"

        # Extract tailnet name and IP
        TAILNET=$(echo "$OUTPUT" | grep -oP '^[^ ]+' | head -1 || true)
        SELF_IP=$(echo "$OUTPUT" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
        EXIT_NODE=$(echo "$OUTPUT" | grep -i "exit node" | head -1 || true)
    else
        STATUS="down"
    fi
fi

# Build tooltip
TOOLTIP="Tailscale: ${STATUS}"
case "$STATUS" in
    up)
        ICON="󰖂"
        CLASS="vpn-up"
        TOOLTIP="Tailscale: connected\nTailnet: ${TAILNET:-?}\nIP: ${SELF_IP:-?}${EXIT_NODE:+\nExit: $EXIT_NODE}"
        ;;
    stopped)
        ICON="󰖂"
        CLASS="vpn-stopped"
        ;;
    *)
        ICON="󰖁"
        CLASS="vpn-down"
        ;;
esac

echo "{\"text\": \"$ICON\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
