#!/bin/sh
# Post-resume hook: ensure WiFi rfkill state file is "unblocked" (0).
# Install to /etc/systemd/system-sleep/fix-wifi-rfkill
#
# Problem: ath11k_pci resets ~5-7 min after resume. When the rfkill device
# reappears, systemd-rfkill.service loads the saved state file. If it was "1"
# from a prior manual disable, WiFi stays blocked.
#
# This hook runs after every resume, ensuring the state file is "0" BEFORE
# the driver reset happens.

case "$1" in
    post)
        for f in /var/lib/systemd/rfkill/*:wlan; do
            [ -f "$f" ] && echo 0 > "$f"
        done
        ;;
esac