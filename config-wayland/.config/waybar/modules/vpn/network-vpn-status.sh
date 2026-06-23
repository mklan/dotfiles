#!/usr/bin/env bash
# Waybar module: combined network + tailscale VPN status
# Outputs JSON with classes for CSS coloring

# ── Tailscale status ──
VPN_CLASS="vpn-down"
VPN_ICON=""
VPN_TOOLTIP="Tailscale: down"
VPN_TEXT=""

if systemctl is-active --quiet tailscaled 2>/dev/null; then
    TS_OUTPUT=$(tailscale status 2>/dev/null || true)
    if echo "$TS_OUTPUT" | grep -q "Tailscale is stopped"; then
        VPN_CLASS="vpn-stopped"
        VPN_TOOLTIP="Tailscale: stopped"
    elif [ -n "$TS_OUTPUT" ]; then
        VPN_CLASS="vpn-up"
        TAILNET=$(echo "$TS_OUTPUT" | grep -oP '^[^ ]+' | head -1 || true)
        SELF_IP=$(echo "$TS_OUTPUT" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
        VPN_TEXT="$VPN_ICON"
        VPN_TOOLTIP="Tailscale: connected\nTailnet: ${TAILNET:-?}\nIP: ${SELF_IP:-?}"
    fi
fi

# Show VPN icon when connected, empty otherwise (hidden in collapsed group)
if [ "$VPN_CLASS" != "vpn-up" ]; then
    VPN_TEXT="$VPN_ICON"
fi

# ── Network status ──
# Check primary connection
WIFI_ICON="󰤢"
WIFI_CLASS=""
WIFI_TOOLTIP=""

# Get network info via nmcli
if command -v nmcli &>/dev/null; then
    CON_STATE=$(nmcli -t -f STATE general 2>/dev/null || echo "unknown")
    WIFI_DEV=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | grep ":wifi:" | head -1 || true)
    
    if [ -n "$WIFI_DEV" ]; then
        DEV=$(echo "$WIFI_DEV" | cut -d: -f1)
        DEV_STATE=$(echo "$WIFI_DEV" | cut -d: -f3)
        
        # Get signal strength
        SIGNAL=$(nmcli -t -f IN-USE,SIGNAL device wifi list 2>/dev/null | grep "^\*:" | cut -d: -f2 | head -1 || echo "0")
        
        # Choose icon based on signal
        if [ "$SIGNAL" -gt 80 ]; then WIFI_ICON="󰤨"
        elif [ "$SIGNAL" -gt 60 ]; then WIFI_ICON="󰤨"
        elif [ "$SIGNAL" -gt 40 ]; then WIFI_ICON="󰤨"
        elif [ "$SIGNAL" -gt 20 ]; then WIFI_ICON="󰤢"
        else WIFI_ICON="󰤢"
        fi
        
        # Get SSID
        SSID=$(nmcli -t -f GENERAL.CONNECTION device show "$DEV" 2>/dev/null | cut -d: -f2 | head -1 || echo "?")
        # Get IP
        IP=$(nmcli -t -f IP4.ADDRESS device show "$DEV" 2>/dev/null | cut -d: -f2 | cut -d/ -f1 | head -1 || echo "?")
        
        WIFI_TOOLTIP="${SSID} (${SIGNAL}%)\nIP: ${IP}"
        
        # Color wifi icon if VPN is up
        if [ "$VPN_CLASS" = "vpn-up" ]; then
            WIFI_CLASS="wifi-vpn-up"
        fi
    else
        # Check ethernet
        ETH_DEV=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | grep ":ethernet:" | head -1 || true)
        if [ -n "$ETH_DEV" ]; then
            WIFI_ICON="󰈀"
            DEV=$(echo "$ETH_DEV" | cut -d: -f1)
            IP=$(nmcli -t -f IP4.ADDRESS device show "$DEV" 2>/dev/null | cut -d: -f2 | cut -d/ -f1 | head -1 || echo "?")
            WIFI_TOOLTIP="Ethernet\nIP: ${IP}"
        else
            WIFI_ICON="󰌙"
            WIFI_TOOLTIP="Disconnected"
            WIFI_CLASS="network-down"
        fi
    fi
else
    WIFI_TOOLTIP="nmcli not available"
fi

cat <<EOF
{"text": "$WIFI_ICON $VPN_TEXT", "class": "$WIFI_CLASS", "tooltip": "$WIFI_TOOLTIP\n$VPN_TOOLTIP"}
EOF
