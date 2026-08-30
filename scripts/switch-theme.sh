#!/bin/bash

# Everforest theme switcher
# Usage: switch-theme [dark|light]
#
# dark  – everforest_oled (OLED black background)
# light – everforest_light (warm white background)
#
# What gets updated:
#   - pywal (regenerates all ~/.cache/wal/* templates)
#   - waybar CSS
#   - dunst
#   - kitty (SIGUSR1)
#   - hyprland colors (via wal cache)
#   - VSCode workbench.colorTheme
#   - GTK theme via gsettings
#   - GTK3 user CSS (~/.config/gtk-3.0/colors.css)
#   - oomox GTK theme rebuild (if oomox-cli is available)

THEME="${1:-dark}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
WAL_DIR="$DOTFILES_DIR/config/.config/wal"

# VSCode theme names (sainnhe.everforest extension)
VSCODE_DARK_THEME="Everforest Dark (Hard)"
VSCODE_LIGHT_THEME="Everforest Light (Hard)"

# GTK theme names (pre-built oomox themes in ~/.themes or /usr/share/themes)
GTK_DARK_THEME="oomox-eboda"
GTK_LIGHT_THEME="oomox-eboda-light"

# oomox output theme name when rebuilding via oomox-cli
OOMOX_OUT_THEME="oomox-wal"

case "$THEME" in
    dark|oled)
        WAL_SCHEME="$WAL_DIR/colorschemes/dark/everforest_oled.json"
        VSCODE_THEME="$VSCODE_DARK_THEME"
        GTK_THEME="$GTK_DARK_THEME"
        GTK_COLOR_SCHEME="prefer-dark"
        ;;
    light)
        WAL_SCHEME="$WAL_DIR/colorschemes/light/everforest_light.json"
        VSCODE_THEME="$VSCODE_LIGHT_THEME"
        GTK_THEME="$GTK_LIGHT_THEME"
        GTK_COLOR_SCHEME="prefer-light"
        ;;
    *)
        echo "Usage: switch-theme [dark|light]"
        exit 1
        ;;
esac

if [ ! -f "$WAL_SCHEME" ]; then
    echo "Error: colorscheme not found: $WAL_SCHEME" >&2
    exit 1
fi

# ── 1. Regenerate all pywal templates ────────────────────────────────────────
echo "Applying pywal scheme: $WAL_SCHEME"
wal -l --theme "$WAL_SCHEME"

# ── 2. Waybar ─────────────────────────────────────────────────────────────────
touch ~/.config/waybar/style.css
if [ -f ~/.cache/wal/waybar-style.css.tpl ]; then
    mkdir -p ~/.config/waybar
    cp ~/.cache/wal/waybar-style.css.tpl ~/.config/waybar/style.css
    pkill -SIGUSR2 waybar 2>/dev/null || true
fi

# ── 3. Dunst ──────────────────────────────────────────────────────────────────
pkill dunst 2>/dev/null
dunst &>/dev/null & disown

# ── 4. Kitty ──────────────────────────────────────────────────────────────────
# SIGUSR1 makes kitty reload its config (picks up updated ~/.cache/wal/colors-kitty.conf)
pkill -SIGUSR1 kitty 2>/dev/null || true

# ── 5. GTK3 user CSS ──────────────────────────────────────────────────────────
# Write a gtk.css that imports the wal-generated colors so GTK3 apps pick up
# the palette even without a full oomox rebuild.
if [ -f ~/.cache/wal/colors-gtk.css ]; then
    mkdir -p ~/.config/gtk-3.0
    cp ~/.cache/wal/colors-gtk.css ~/.config/gtk-3.0/colors.css
    # Create gtk.css that imports colors if it doesn't already do so
    GTK3_CSS="$HOME/.config/gtk-3.0/gtk.css"
    if [ ! -f "$GTK3_CSS" ] || ! grep -q "colors.css" "$GTK3_CSS"; then
        echo '@import url("colors.css");' | cat - "$GTK3_CSS" 2>/dev/null > /tmp/gtk3_tmp.css && mv /tmp/gtk3_tmp.css "$GTK3_CSS"
    fi
fi

# ── 6. GTK theme via gsettings ────────────────────────────────────────────────
if command -v gsettings &>/dev/null; then
    # Prefer oomox-wal if it was just built, fall back to the named theme
    if [ -d "$HOME/.themes/$OOMOX_OUT_THEME" ] || [ -d "/usr/share/themes/$OOMOX_OUT_THEME" ]; then
        gsettings set org.gnome.desktop.interface gtk-theme "$OOMOX_OUT_THEME" 2>/dev/null || true
    elif [ -d "$HOME/.themes/$GTK_THEME" ] || [ -d "/usr/share/themes/$GTK_THEME" ]; then
        gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true
    fi
    gsettings set org.gnome.desktop.interface color-scheme "$GTK_COLOR_SCHEME" 2>/dev/null || true
fi

# ── 7. oomox GTK theme rebuild (optional) ─────────────────────────────────────
# Run only when oomox-cli is available and the wal colors file was generated.
if command -v oomox-cli &>/dev/null && [ -f ~/.cache/wal/colors.oomox ]; then
    echo "Rebuilding oomox GTK theme…"
    oomox-cli -o "$OOMOX_OUT_THEME" ~/.cache/wal/colors.oomox && \
    command -v gsettings &>/dev/null && \
        gsettings set org.gnome.desktop.interface gtk-theme "$OOMOX_OUT_THEME" 2>/dev/null || true
fi

# ── 8. VSCode / VSCodium ──────────────────────────────────────────────────────
for SETTINGS_FILE in \
    "$HOME/.config/Code/User/settings.json" \
    "$HOME/.config/Code - OSS/User/settings.json" \
    "$HOME/.config/VSCodium/User/settings.json"; do

    if [ -f "$SETTINGS_FILE" ]; then
        if command -v jq &>/dev/null; then
            tmp=$(mktemp)
            jq --arg t "$VSCODE_THEME" '."workbench.colorTheme" = $t' "$SETTINGS_FILE" > "$tmp" \
                && mv "$tmp" "$SETTINGS_FILE"
        else
            # Fallback: sed-based replacement (handles simple cases)
            sed -i "s|\"workbench.colorTheme\":.*|\"workbench.colorTheme\": \"$VSCODE_THEME\",|" \
                "$SETTINGS_FILE"
        fi
        echo "VSCode theme set to: $VSCODE_THEME  ($SETTINGS_FILE)"
    fi
done

echo "Done. Theme: $THEME"
