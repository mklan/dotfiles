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
#   - quickshell bar (restart → picks up ~/.cache/wal/colors.json via theme.qml)
#   - dunst
#   - kitty (SIGUSR1)
#   - hyprland colors (via wal cache)
#   - VSCode workbench.colorTheme – dark: Blackforest extension (pure-black
#     OLED void), light: generated "Wal Light" theme; "Wal OLED" and "Wal Light"
#     are generated from the wal schemes into the managed extension
#     wal.wal-palette (scripts/gen-vscode-theme.py)
#   - GTK3 live theme switch: the wal palette is deployed as a real theme
#     (~/.themes/wal-<mode>) and switched via org.gnome.desktop.interface
#     gtk-theme – running GTK3 apps restyle instantly (GTK3 never re-reads
#     user CSS, so ~/.config/gtk-3.0/gtk.css is not used)
#   - GTK4/libadwaita palette surfaces (colors.css + gtk-surfaces.css – GTK4
#     hot-reloads those files on change)
#   - GTK2 fallback palette (~/.gtkrc-2.0.mine)
#   - Qt5/Qt6 follow the GTK palette via QT_QPA_PLATFORMTHEME=gtk3 (see envs.lua)
#   - Firefox userChrome.css + userContent.css as dual light-dark() palettes
#     (all non-headless profiles; they recolor live via the color-scheme flip,
#     store themes are pinned off via extensions.activeThemeID in user.js)

THEME="${1:-dark}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
WAL_DIR="$DOTFILES_DIR/config/.config/wal"

# VSCode themes. "Wal OLED" / "Wal Light" are generated from the wal schemes
# in step 7 (managed extension wal.wal-palette). Dark keeps the Blackforest
# extension (pure-black OLED void) by default – set VSCODE_DARK_THEME="Wal OLED"
# for a palette-exact dark theme that matches the rest of the desktop.
VSCODE_DARK_THEME="Blackforest"
VSCODE_LIGHT_THEME="Wal Light"

# The wal scheme pair drives the dual-palette Firefox CSS (light-dark() pairs)
WAL_SCHEME_DARK="$WAL_DIR/colorschemes/dark/everforest_oled.json"
WAL_SCHEME_LIGHT="$WAL_DIR/colorschemes/light/everforest_light.json"

case "$THEME" in
    dark|oled)
        WAL_SCHEME="$WAL_SCHEME_DARK"
        VSCODE_THEME="$VSCODE_DARK_THEME"
        GTK_COLOR_SCHEME="prefer-dark"
        GTK_PREFER_DARK=1
        UI_MODE="dark"
        ;;
    light)
        WAL_SCHEME="$WAL_SCHEME_LIGHT"
        VSCODE_THEME="$VSCODE_LIGHT_THEME"
        GTK_COLOR_SCHEME="prefer-light"
        GTK_PREFER_DARK=0
        UI_MODE="light"
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
# -s = don't push escape sequences into /dev/pts/*: any stale pty whose master
# isn't being read (leaked adb shell pty, closed VSCode terminal, …) has a
# full output queue and makes wal block forever. Kitty recolors via
# colors-kitty.conf + SIGUSR1 (step 5) instead.
wal -l -s --theme "$WAL_SCHEME"

# ── 2. Hyprland colors ─────────────────────────────────────────────────────────
# styling.lua reads ~/.cache/wal/colors-hyprland.conf at config load – reload
# right after wal so window borders flip together with the bar (which
# recolors the moment colors.json lands). Anything not in lock-step runs
# after the gsettings flip – keep all visible triggers back-to-back.
hyprctl reload >/dev/null 2>&1 || true

# ── 3. GTK3 theme (live-switchable) + GTK4 user CSS + GTK2 fallback ─────────
# GTK3 never re-reads ~/.config/gtk-3.0/gtk.css in running apps – user CSS is
# parsed once at startup and then frozen. The only live lever is a gtk-theme
# change (GSettings), so the palette is deployed as a real GTK3 theme and
# switched in step 4. GTK4/libadwaita hot-reloads ~/.config/gtk-4.0/gtk.css
# instead, so it keeps the user-CSS deployment. All generated files are fully
# managed – don't edit.
GTK_THEME_NAME="wal-$UI_MODE"   # wal-dark / wal-light

if [ -f ~/.cache/wal/colors-gtk.css ]; then

    # GTK3 theme: Adwaita base (widget shapes etc.) + wal palette + the
    # surface rules that force the palette onto the widgets
    if [ "$UI_MODE" = "dark" ]; then
        ADWAITA_IMPORT="resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css"
    else
        ADWAITA_IMPORT="resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained.css"
    fi
    mkdir -p "$HOME/.themes/$GTK_THEME_NAME/gtk-3.0"
    {
        echo "@import url(\"$ADWAITA_IMPORT\");"
        cat ~/.cache/wal/colors-gtk.css
        grep -v '@import url("colors.css")' "$DOTFILES_DIR/config/.config/gtk/gtk-surfaces.css"
    } > "$HOME/.themes/$GTK_THEME_NAME/gtk-3.0/gtk.css"

    # GTK4 / libadwaita: user CSS (hot-reloaded on file change)
    mkdir -p "$HOME/.config/gtk-4.0"
    cp ~/.cache/wal/colors-gtk.css "$HOME/.config/gtk-4.0/colors.css"
    cp "$DOTFILES_DIR/config/.config/gtk/gtk-surfaces.css" "$HOME/.config/gtk-4.0/gtk.css"

    # GTK3 user CSS must not linger: a stale frozen copy would override the
    # live theme in already-running GTK3 apps
    rm -f "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/colors.css"
fi

# GTK2 has no access to the wal palette at runtime – generate its palette
# fallback from the same colors (legacy apps only).
if [ -f ~/.cache/wal/colors.sh ]; then
    # shellcheck disable=SC1091
    . ~/.cache/wal/colors.sh
    cat > "$HOME/.gtkrc-2.0.mine" <<EOF
# Generated by switch-theme.sh – GTK2 palette fallback (the old oomox GTK2
# theme is gone; stock GTK2 themes are light).

gtk-color-scheme = "bg_color:${background}\\nfg_color:${foreground}\\ntext_color:${foreground}\\nbase_color:${background}\\nselected_bg_color:${color5}\\nselected_fg_color:${color0}\\ninsensitive_bg_color:${background}\\ninsensitive_fg_color:${color8}\\ntooltip_bg_color:${background}\\ntooltip_fg_color:${foreground}"

style "wal-palette"
{
 bg[NORMAL] = "${background}"
 bg[ACTIVE] = "${background}"
 bg[PRELIGHT] = "${color8}"
 bg[SELECTED] = "${color5}"
 bg[INSENSITIVE] = "${background}"

 fg[NORMAL] = "${foreground}"
 fg[ACTIVE] = "${foreground}"
 fg[PRELIGHT] = "${color0}"
 fg[SELECTED] = "${color0}"
 fg[INSENSITIVE] = "${color8}"

 base[NORMAL] = "${background}"
 base[ACTIVE] = "${background}"
 base[PRELIGHT] = "${color8}"
 base[SELECTED] = "${color5}"
 base[INSENSITIVE] = "${background}"

 text[NORMAL] = "${foreground}"
 text[ACTIVE] = "${foreground}"
 text[PRELIGHT] = "${color0}"
 text[SELECTED] = "${color0}"
 text[INSENSITIVE] = "${color8}"
}

class "*" style "wal-palette"
EOF
fi

# ── 4. GTK theme via gsettings (live restyle) ─────────────────────────────────
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme "$GTK_COLOR_SCHEME" 2>/dev/null || true

    # Running GTK3 apps restyle instantly when gtk-theme changes – but
    # GSettings emits no notification when the value is unchanged, so hop
    # through Adwaita first when re-applying the same name (new wallpaper
    # colors within the same mode).
    if [ "$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")" = "$GTK_THEME_NAME" ]; then
        gsettings set org.gnome.desktop.interface gtk-theme Adwaita 2>/dev/null || true
        sleep 0.3
    fi
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME" 2>/dev/null || true
fi
# Keep the settings.ini fallback (written by nwg-look) in sync
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
    sed -i -e "s/^gtk-theme-name=.*/gtk-theme-name=$GTK_THEME_NAME/" \
           -e "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$GTK_PREFER_DARK/" \
           "$HOME/.config/gtk-3.0/settings.ini"
fi

# ── 5. Kitty ──────────────────────────────────────────────────────────────────
# SIGUSR1 makes kitty reload its config (picks up updated ~/.cache/wal/colors-kitty.conf)
pkill -SIGUSR1 kitty 2>/dev/null || true

# ── 6. Waybar ─────────────────────────────────────────────────────────────────
touch ~/.config/waybar/style.css
if [ -f ~/.cache/wal/waybar-style.css.tpl ]; then
    mkdir -p ~/.config/waybar
    cp ~/.cache/wal/waybar-style.css.tpl ~/.config/waybar/style.css
    pkill -SIGUSR2 waybar 2>/dev/null || true
fi

# ── 6b. Quickshell bar ──────────────────────────────────────────────────────────
# The bar recolors LIVE on theme switches: theme.qml watches
# ~/.cache/wal/colors.json (FileView watchChanges + onFileChanged: reload())
# and every module binds its colors to Theme.*, so the bar must NOT be
# restarted – its disappearance made windows reflow around the vanished
# exclusive zone (resize glitches). Only (re)start it when it is not running.
if ! pgrep -x quickshell >/dev/null 2>&1; then
    "$DOTFILES_DIR/scripts/restart_app" quickshell 2>/dev/null || true
fi

# ── 6c. hyproled (OLED burn-in shader) ─────────────────────────────────────────
# Enabled/disabled per theme via ~/.config/hypr/hyproled.conf – the wrapper
# turns the call into "hyproled off" when the active theme disables it.
echo "$UI_MODE" > "$HOME/.cache/theme-mode"
"$DOTFILES_DIR/config-wayland/.config/hypr/scripts/hyproled.sh" -s -a 0:0:2880:45 || true

# ── 6d. Dunst ──────────────────────────────────────────────────────────────────
pkill dunst 2>/dev/null
dunst &>/dev/null & disown

# ── 7. VSCode / VSCodium ──────────────────────────────────────────────────────
# Two themes are generated from the wal scheme files into a small managed
# extension (wal.wal-palette) with scripts/gen-vscode-theme.py:
#   Wal OLED  – from WAL_SCHEME_DARK
#   Wal Light – from WAL_SCHEME_LIGHT
# The theme files are deterministic per scheme – they only change when the
# scheme files change (VSCode re-reads theme files at startup, so that needs
# a restart). Flipping workbench.colorTheme below is live. First run only:
# VSCode must be restarted once before it sees the new extension.
VSCODE_THEME_ID="wal.wal-palette-0.0.1"
for EXT_DIR in "$HOME/.vscode/extensions" "$HOME/.vscode-oss/extensions"; do
    [ -d "$EXT_DIR" ] || continue
    THEME_EXT="$EXT_DIR/$VSCODE_THEME_ID"
    mkdir -p "$THEME_EXT/themes"
    if [ ! -f "$THEME_EXT/package.json" ]; then
        cat > "$THEME_EXT/package.json" <<'EOF'
{
  "name": "wal-palette",
  "displayName": "Wal Palette",
  "description": "pywal-generated themes (managed by dotfiles/switch-theme.sh)",
  "version": "0.0.1",
  "publisher": "wal",
  "engines": { "vscode": "^1.60.0" },
  "categories": ["Themes"],
  "contributes": {
    "themes": [
      { "label": "Wal OLED", "uiTheme": "vs-dark", "path": "./themes/wal-oled.json" },
      { "label": "Wal Light", "uiTheme": "vs", "path": "./themes/wal-light.json" }
    ]
  }
}
EOF
        echo "VSCode: created theme extension $THEME_EXT (restart VSCode once to load it)"
    fi
    python3 "$DOTFILES_DIR/scripts/gen-vscode-theme.py" \
        "$WAL_SCHEME_DARK" "$THEME_EXT/themes/wal-oled.json" "Wal OLED" dark
    python3 "$DOTFILES_DIR/scripts/gen-vscode-theme.py" \
        "$WAL_SCHEME_LIGHT" "$THEME_EXT/themes/wal-light.json" "Wal Light" light
done

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

# ── 8. Firefox (userChrome.css / userContent.css) ─────────────────────────────
# The templates are rendered as DUAL palettes: every color becomes a
# light-dark(<light>, <dark>) pair (scripts/gen-ff-theme.py). Firefox resolves
# light-dark() against prefers-color-scheme, which follows the color-scheme
# GSettings key flipped in step 6 – so the chrome recolors live on every
# switch and the deployed files are mode-independent. The files themselves are
# still only read at startup: restart Firefox when the template content
# changes (not on ordinary theme switches).
FF_CHROME_CSS=$(mktemp)
FF_CONTENT_CSS=$(mktemp)
python3 "$DOTFILES_DIR/scripts/gen-ff-theme.py" \
    "$WAL_SCHEME_LIGHT" "$WAL_SCHEME_DARK" \
    "$WAL_DIR/templates/firefox-userChrome.css" "$FF_CHROME_CSS"
python3 "$DOTFILES_DIR/scripts/gen-ff-theme.py" \
    "$WAL_SCHEME_LIGHT" "$WAL_SCHEME_DARK" \
    "$WAL_DIR/templates/firefox-userContent.css" "$FF_CONTENT_CSS"

if [ -s "$FF_CHROME_CSS" ] && [ -s "$FF_CONTENT_CSS" ]; then
    FF_DEPLOYED=0
    FF_NEED_RESTART=0
    for FF_ROOT in "$HOME/.mozilla/firefox" \
                   "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox" \
                   "$HOME/snap/firefox/common/.mozilla/firefox"; do
        for FF_DIR in "$FF_ROOT"/*/; do
            [ -d "$FF_DIR" ] || continue
            case "$FF_DIR" in *headless*) continue ;; esac
            [ -f "$FF_DIR/prefs.js" ] || continue

            mkdir -p "$FF_DIR/chrome"

            # the deployed file is mode-independent – a restart is only needed
            # when an older single-palette version gets replaced
            grep -q 'light-dark(#' "$FF_DIR/chrome/userChrome.css" 2>/dev/null || FF_NEED_RESTART=1

            cp "$FF_CHROME_CSS" "$FF_DIR/chrome/userChrome.css"
            cp "$FF_CONTENT_CSS" "$FF_DIR/chrome/userContent.css"

            # user.js is re-applied at every startup – keep one managed block in it
            FF_USERJS="$FF_DIR/user.js"
            touch "$FF_USERJS"
            # ensure a trailing newline so the marker lines stay at line start
            # (otherwise the managed block can't be replaced on the next run)
            [ -n "$(tail -c1 "$FF_USERJS")" ] && echo >> "$FF_USERJS"
            sed -i '\|^/\* >>> wal firefox >>>|,\|^/\* <<< wal firefox <<<|d' "$FF_USERJS"
            cat >> "$FF_USERJS" <<'EOF'
/* >>> wal firefox >>> — managed by switch-theme.sh, do not edit in between */
// userChrome.css / userContent.css are generated from the pywal templates
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Pin the built-in theme so the wal palette owns the colors (remove this line
// to go back to themes from the store – but they will fight the wal palette)
user_pref("extensions.activeThemeID", "default-theme@mozilla.org");
// Firefox Sync re-installs and re-activates store themes from other synced
// devices minutes after startup (e.g. the "Black" theme, id
// {9b84b6b4-07c4-4b4b-ba21-394d86f6e9ee}). An active dark LWT theme forces
// the chrome AND prefers-color-scheme dark, so both userChrome.css and
// userContent.css get stuck on the dark half of their light-dark() palettes –
// no theme switch and no Firefox restart can win against sync re-poisoning.
// Pin the theme selection and take the theme business away from sync:
user_pref("services.sync.prefs.sync.extensions.activeThemeID", false);
user_pref("services.sync.prefs.sync.browser.theme.toolbar-theme", false);
user_pref("services.sync.prefs.sync.browser.theme.content-theme", false);
user_pref("services.sync.prefs.sync.browser.theme.native-theme", false);
user_pref("services.sync.prefs.sync.layout.css.prefers-color-scheme.content-override", false);
user_pref("services.sync.prefs.sync.ui.systemUsesDarkTheme", false);
// The add-on sync engine re-installs the store theme xpi itself – disable it
// (drop this line if you want add-on sync back, but the theme can return)
user_pref("services.sync.engine.addons.enabled", false);
/* <<< wal firefox <<< */
EOF
            echo "Firefox: deployed theme to $FF_DIR"
            FF_DEPLOYED=1
        done
    done
    if [ "$FF_NEED_RESTART" = 1 ] && pgrep -x firefox >/dev/null 2>&1; then
        echo "Firefox: restart Firefox once – after that, theme switches apply live"
    fi
fi
rm -f "$FF_CHROME_CSS" "$FF_CONTENT_CSS"

echo "Done. Theme: $THEME"
