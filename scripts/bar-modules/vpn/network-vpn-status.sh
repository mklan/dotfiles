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
    TS_OUTPUT=$(timeout 3 tailscale status 2>/dev/null || true)
    if echo "$TS_OUTPUT" | grep -q "Tailscale is stopped"; then
        VPN_CLASS="vpn-stopped"
        VPN_TOOLTIP="Tailscale: stopped"
    elif [ -n "$TS_OUTPUT" ]; then
        VPN_CLASS="vpn-up"
        VPN_REASON="Tailscale"
        TAILNET=$(echo "$TS_OUTPUT" | grep -oP '^[^ ]+' | head -1 || true)
        SELF_IP=$(echo "$TS_OUTPUT" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
        VPN_TOOLTIP="Tailscale: connected\nTailnet: ${TAILNET:-?}\nIP: ${SELF_IP:-?}"
    fi
fi

# ── Home router check (async, cached 10s, atomic writes) ──
# 192.168.1.1 = home router; reachable = on home network (travel router, LAN, etc.)
# The ping is fire-and-forget so it never blocks the bar update; its result lands
# in the cache ATOMICALLY (tmp file + mv) and is picked up on the next poll.
# Never write the cache with a plain '>' from the background job: the redirect
# truncates the file *before* the ping runs, and the reader then sees an empty
# file → "unreachable" → icon flaps gray every other poll (the old bug).
ROUTER_CACHE="/tmp/waybar-router-ping"
ROUTER_TTL=10

router_ping() {
    # 2 attempts: a single dropped packet (Wi-Fi hiccup) must not flip the state
    ping -c2 -i 0.3 -W1 192.168.1.1 &>/dev/null && echo up || echo down
}

router_write() {
    printf '%s\n' "$1" > "${ROUTER_CACHE}.tmp.$$" && mv -f "${ROUTER_CACHE}.tmp.$$" "$ROUTER_CACHE"
}

CACHE_VAL=$(cat "$ROUTER_CACHE" 2>/dev/null)
CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$ROUTER_CACHE" 2>/dev/null || echo 0) ))

if [ "$CACHE_VAL" != "up" ] && [ "$CACHE_VAL" != "down" ]; then
    # No usable cache yet (first run / leftover empty file from the old version):
    # check synchronously so the very first bar update is already correct.
    router_write "$(router_ping)"
    CACHE_VAL=$(cat "$ROUTER_CACHE" 2>/dev/null)
elif [ "$CACHE_AGE" -ge "$ROUTER_TTL" ]; then
    # Refresh in the background; keep serving the previous (valid) value.
    ( router_write "$(router_ping)" ) &
fi

if [ "$CACHE_VAL" = "up" ]; then
    HOME_REACHABLE=true
    HOME_TOOLTIP="Home network: reachable"
else
    HOME_TOOLTIP="Home network: unreachable"
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
    # Prefer the *connected* wifi device (skip virtual p2p-* clones of wlan0),
    # fall back to the first real one so a disconnected state still displays.
    WIFI_CANDIDATES=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | grep ":wifi:" | grep -v "^p2p-" || true)
    WIFI_DEV=$(echo "$WIFI_CANDIDATES" | awk -F: '$3 == "connected"' | head -1)
    [ -z "$WIFI_DEV" ] && WIFI_DEV=$(echo "$WIFI_CANDIDATES" | head -1)
    
    if [ -n "$WIFI_DEV" ]; then
        DEV=$(echo "$WIFI_DEV" | cut -d: -f1)
        DEV_STATE=$(echo "$WIFI_DEV" | cut -d: -f3)
        
        # Get signal strength (--rescan no: a forced rescan every 5s is slow and
        # can disturb the link; we only want the cached scan table)
        SIGNAL=$(nmcli -t -f IN-USE,SIGNAL device wifi list --rescan no 2>/dev/null | grep "^\*:" | cut -d: -f2 | head -1)
        case "$SIGNAL" in (*[!0-9]*|"") SIGNAL=0 ;; esac
        
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
        else
            WIFI_CLASS="wifi-up"
        fi
    else
        # Check ethernet
        ETH_CANDIDATES=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null | grep ":ethernet:" | grep -v "^p2p-" || true)
        ETH_DEV=$(echo "$ETH_CANDIDATES" | awk -F: '$3 == "connected"' | head -1)
        [ -z "$ETH_DEV" ] && ETH_DEV=$(echo "$ETH_CANDIDATES" | head -1)
        if [ -n "$ETH_DEV" ]; then
            WIFI_ICON="󰈀"
            DEV=$(echo "$ETH_DEV" | cut -d: -f1)
            ETH_STATE=$(echo "$ETH_DEV" | cut -d: -f3)
            IP=$(nmcli -t -f IP4.ADDRESS device show "$DEV" 2>/dev/null | cut -d: -f2 | cut -d/ -f1 | head -1 || echo "?")
            WIFI_TOOLTIP="Ethernet\nIP: ${IP}"
            # Gray out if disconnected or no IP
            if [ "$ETH_STATE" = "disconnected" ] || [ -z "$IP" ] || [ "$IP" = "?" ]; then
                WIFI_CLASS="network-down"
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

# ── Home override: connected + home reachable → wifi-home ──
if [ "$WIFI_CLASS" = "wifi-up" ] && [ "$HOME_REACHABLE" = "true" ]; then
    WIFI_CLASS="wifi-home"
fi

# ── Assemble tooltip: connection + IP + home reachability + VPN ──
TOOLTIP="$WIFI_TOOLTIP"
[ -n "$HOME_TOOLTIP" ] && TOOLTIP="$TOOLTIP\n$HOME_TOOLTIP"
[ -n "$VPN_TOOLTIP" ] && TOOLTIP="$TOOLTIP\n$VPN_TOOLTIP"

cat <<EOF
{"text": "$WIFI_ICON", "class": "$WIFI_CLASS", "tooltip": "$TOOLTIP"}
EOF
