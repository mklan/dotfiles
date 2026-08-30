#!/usr/bin/env bash
# Waybar module: combined network + tailscale VPN status
# Outputs JSON with classes for CSS coloring
# VPN-up (blue) when: Tailscale running, home router reachable, or any tunnel iface

# ── Tailscale status ──
VPN_CLASS="vpn-down"
VPN_ICON=""
VPN_TOOLTIP=""
VPN_TEXT=""
VPN_REASON=""

if systemctl is-active --quiet tailscaled 2>/dev/null; then
    TS_OUTPUT=$(tailscale status 2>/dev/null || true)
    if echo "$TS_OUTPUT" | grep -q "Tailscale is stopped"; then
        VPN_CLASS="vpn-stopped"
        VPN_TOOLTIP="Tailscale: stopped"
    elif [ -n "$TS_OUTPUT" ]; then
        VPN_CLASS="vpn-up"
        VPN_REASON="Tailscale"
        TAILNET=$(echo "$TS_OUTPUT" | grep -oP '^[^ ]+' | head -1 || true)
        SELF_IP=$(echo "$TS_OUTPUT" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
        VPN_TEXT="$VPN_ICON"
        VPN_TOOLTIP="Tailscale: connected\nTailnet: ${TAILNET:-?}\nIP: ${SELF_IP:-?}"
    fi
fi

# ── Home router check (cached every 60s) ──
# 192.168.1.1 = home router; reachable = on home network (travel router, LAN, etc.)
ROUTER_CACHE="/tmp/waybar-router-ping"
if [ "$VPN_CLASS" != "vpn-up" ]; then
    STALE=0
    if [ -f "$ROUTER_CACHE" ]; then
        CACHE_TIME=$(stat -c %Y "$ROUTER_CACHE" 2>/dev/null || echo 0)
        [ "$(($(date +%s) - CACHE_TIME))" -ge 60 ] && STALE=1
    else
        STALE=1
    fi

    if [ "$STALE" = "1" ]; then
        if ping -c1 -W1 192.168.1.1 &>/dev/null; then
            echo "up" > "$ROUTER_CACHE"
        else
            echo "down" > "$ROUTER_CACHE"
        fi
    fi

    if [ "$(cat "$ROUTER_CACHE" 2>/dev/null)" = "up" ]; then
        VPN_CLASS="vpn-up"
        VPN_REASON="Home network"
        VPN_TOOLTIP="Home network: reachable\n(router at 192.168.1.1)"
    fi
fi

# ── Tunnel interface check ──
# Any active tunnel/VPN interface (wg*, tun*, tap*, ppp*) besides tailscale0
if [ "$VPN_CLASS" != "vpn-up" ]; then
    TUN_IFACE=$(ip -br link show 2>/dev/null | grep -E '^wg[0-9]+|^tun[0-9]+|^tap[0-9]+|^ppp[0-9]+' | grep -v 'tailscale0' | awk '{print $1}' | head -1)
    if [ -n "$TUN_IFACE" ]; then
        VPN_CLASS="vpn-up"
        VPN_REASON="Tunnel"
        VPN_TOOLTIP="VPN tunnel: ${TUN_IFACE} active"
    fi
fi

# If VPN-up but no reason was set (should not happen, but guard)
[ -z "$VPN_REASON" ] && [ "$VPN_CLASS" = "vpn-up" ] && VPN_REASON="VPN"

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
        if [ "$SIGNAL" -gt 75 ]; then WIFI_ICON="󰤨"
        elif [ "$SIGNAL" -gt 50 ]; then WIFI_ICON="󰤥"
        elif [ "$SIGNAL" -gt 25 ]; then WIFI_ICON="󰤢"
        else WIFI_ICON="󰤟"
        fi
        
        # Get SSID
        SSID=$(nmcli -t -f GENERAL.CONNECTION device show "$DEV" 2>/dev/null | cut -d: -f2 | head -1 || echo "?")
        # Get IP
        IP=$(nmcli -t -f IP4.ADDRESS device show "$DEV" 2>/dev/null | cut -d: -f2 | cut -d/ -f1 | head -1 || echo "?")
        
        WIFI_TOOLTIP="${SSID} (${SIGNAL}%)\nIP: ${IP}"
        
        # Check if actually disconnected or no IP assigned
        if [ "$DEV_STATE" = "disconnected" ] || [ -z "$IP" ] || [ "$IP" = "?" ]; then
            WIFI_CLASS="network-down"
        elif [ "$VPN_CLASS" = "vpn-up" ]; then
            WIFI_CLASS="wifi-vpn-up"
        else
            WIFI_CLASS="wifi-up"
        fi
    else
        # Check ethernet
        ETH_DEV=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | grep ":ethernet:" | head -1 || true)
        if [ -n "$ETH_DEV" ]; then
            WIFI_ICON="󰈀"
            DEV=$(echo "$ETH_DEV" | cut -d: -f1)
            ETH_STATE=$(echo "$ETH_DEV" | cut -d: -f3)
            IP=$(nmcli -t -f IP4.ADDRESS device show "$DEV" 2>/dev/null | cut -d: -f2 | cut -d/ -f1 | head -1 || echo "?")
            WIFI_TOOLTIP="Ethernet\nIP: ${IP}"
            # Gray out if disconnected or no IP
            if [ "$ETH_STATE" = "disconnected" ] || [ -z "$IP" ] || [ "$IP" = "?" ]; then
                WIFI_CLASS="network-down"
            elif [ "$VPN_CLASS" = "vpn-up" ]; then
                WIFI_CLASS="wifi-vpn-up"
            else
                WIFI_CLASS="wifi-up"
            fi
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
