#!/usr/bin/env bash
# hyproled wrapper – respects the per-theme config in ~/.config/hypr/hyproled.conf.
#
# Usage: hyproled.sh [hyproled args...] | hyproled.sh off
#
# When hyproled is disabled for the active theme, every call is turned into
# "hyproled off" so the shader is never left active on a theme that doesn't
# want it. The active theme lives in ~/.cache/theme-mode (written by
# scripts/switch-theme.sh).

CONF="$HOME/.config/hypr/hyproled.conf"
[ -f "$CONF" ] && . "$CONF"

MODE=$(cat "$HOME/.cache/theme-mode" 2>/dev/null || echo dark)
case "$MODE" in
    light) ENABLED="${HYPROLED_LIGHT:-off}" ;;
    *)     ENABLED="${HYPROLED_DARK:-on}" ;;
esac

if [ "$1" != "off" ] && [ "$ENABLED" = "on" ]; then
    exec hyproled "$@"
fi
exec hyproled off
