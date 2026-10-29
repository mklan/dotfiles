# AGENTS.md — System Overview

## OS

- **Arch Linux** — kernel 7.0.x, rolling release

## Compositor

- **Hyprland 0.56.2** — Wayland compositor
- Config: `~/.config/hypr/hyprland.lua` (Lua config manager — **active**)
- Config provider: `lua` (`hyprctl systeminfo` shows `configProvider: lua`)
  - `hyprctl eval '<lua>'` works and runs against the live Lua state
  - The old hyprlang `windowrulev2` syntax is gone — everything is `hl.*` Lua API now
- Modules loaded via `require("conf.<name>")` from: `~/.config/hypr/conf/` (envs, monitors, input, styling, animations, binds, windowrules, autostart)
- Window rules: `~/.config/hypr/conf/windowrules.lua` (`hl.window_rule()`, `hl.layer_rule()`)
- Window-rule matcher semantics (verified empirically, 2026-10):
  - match values are **ECMAScript regexes matched against the ENTIRE string** (full-match) — wrap in `.*…*` for substring matching
  - available match properties: `class`, `initial_class`, `title`, `initial_title`, `tag`, `xdg_tag`, `xwayland`, `fullscreen`, `focus`, `workspace`, `content`, `modal`
  - `modal = true` only catches toolkits that announce modality (GTK4, Qt5/6, Electron); GTK3 dialogs never send `set_modal`, catch those via `initial_title`
  - `initial_title` is frozen at map time — safe against later title changes (browser tabs)
  - a `float` rule applied at map time keeps the window's natural size (popup/dialog behavior)

## Theming — pywal (wal)

- **Color theme**: `everforest_oled.json` — pitch black (`#000000`) background, evergreen accents
- Theme file: `~/.config/wal/colorschemes/dark/everforest_oled.json`
- Templates live in: `~/.config/wal/templates/`
- All templates use `{color0}`, `{color1}`, …, `{color15}`, `{background}`, `{foreground}` placeholders
- Apply changes: `~/dotfiles/scripts/reload_wal.sh`

### pywal-generated files (symlinked or copied from `~/.cache/wal/`)

| Template                | Deployed to                                                | Mechanism                               |
| ----------------------- | ---------------------------------------------------------- | --------------------------------------- |
| `waybar-style.css.tpl`  | `~/.config/waybar/style.css`                               | `cp` via reload_wal.sh                  |
| `dunstrc`               | `~/.cache/wal/dunstrc` → symlink `~/.config/dunst/dunstrc` | wal generates into cache, user symlinks |
| `colors-hyprland.conf`  | `~/.cache/wal/colors-hyprland.conf`                        | wal generates                           |
| `colors-kitty.conf`     | `~/.cache/wal/colors-kitty.conf`                           | wal generates                           |
| `colors-rofi-dark.rasi` | `~/.cache/wal/colors-rofi-dark.rasi`                       | wal generates                           |
| `colors-gtk.css`        | `~/.config/gtk-4.0/colors.css` + inlined into `~/.themes/wal-<mode>/gtk-3.0/gtk.css` | `switch-theme.sh` (palette defines) |
| `gtk-surfaces.css` (static, `config/.config/gtk/`) | `~/.config/gtk-4.0/gtk.css` + inlined into `~/.themes/wal-<mode>/gtk-3.0/gtk.css` | `switch-theme.sh` (palette widget rules) |
| `firefox-userChrome.css`  | `<profile>/chrome/userChrome.css` (all non-headless Firefox profiles) | rendered by `scripts/gen-ff-theme.py` into `light-dark()` pairs, `cp` via `switch-theme.sh` |
| `firefox-userContent.css` | `<profile>/chrome/userContent.css` (all non-headless Firefox profiles) | rendered by `scripts/gen-ff-theme.py` into `light-dark()` pairs, `cp` via `switch-theme.sh` |

## Bar

- **Waybar 0.15.0** — top bar, 22px height
- Config: `~/.config/waybar/config` (JSON)
- CSS: `~/.config/waybar/style.css` — **auto-generated** by pywal from `waybar-style.css.tpl` template
- Reload: `pkill -SIGUSR2 waybar`
- Layout: left (apps + workspaces), center (clock + weather), right (todo + hardware + connection + stats + power)

## Notifications

- **Dunst 1.13.2** — lightweight notification daemon
- Config: `~/.config/dunst/dunstrc` → symlink to `~/.cache/wal/dunstrc`
- Template: `~/.config/wal/templates/dunstrc` (pywal-managed)
- Position: top-right, offset `4,22` (sits below waybar)
- Restart: `pkill dunst && dunst &`

## Terminal

- **Kitty 0.47.1** — GPU-accelerated terminal
- Colors via wal-generated `colors-kitty.conf`

## App Launcher

- **Rofi 2.0.0** — Wayland-native mode
- Colors via wal-generated `colors-rofi-dark.rasi`
- Window rules: floats, stays focused, blur layer rule

## Browser

- **Firefox 158** — native install (`/usr/bin/firefox`), profiles in `~/.mozilla/firefox/`
- Chrome is pywal-themed via `userChrome.css` + `userContent.css` (rendered from the `firefox-userChrome.css` / `firefox-userContent.css` templates by `scripts/gen-ff-theme.py`)
- `switch-theme.sh` deploys them into every non-headless profile's `chrome/` dir and keeps a managed block in `<profile>/user.js` that enables `toolkit.legacyUserProfileCustomizations.stylesheets` and pins `extensions.activeThemeID` to `default-theme@mozilla.org` (store themes are disabled on purpose — they fight the wal palette)
- **Theme switches apply live, no Firefox restart**: every color in the generated CSS is a `light-dark(<light>, <dark>)` pair and the templates declare `color-scheme: light dark` on `:root`; Firefox resolves `light-dark()` against `prefers-color-scheme`, which tracks `org.gnome.desktop.interface color-scheme` at runtime (verified empirically 2026-10: content `matchMedia`, chrome UI and Dark Reader all flip on `switch-theme.sh dark|light`). Two gotchas (both handled in the template): (1) Firefox's theme machinery forces `color-scheme` on chrome subtrees (`lwt-toolbar` → `--toolbar-color-scheme`) – the template forces `color-scheme: light dark !important` on `#main-window *` so `light-dark()` follows the system again; (2) the urlbar subtree resolves `light-dark()` in custom properties against its own forced scheme (the pill went dark in light mode) – the field vars are registered via `@property` so they resolve at `:root` and inherit as plain colors. The deployed files are mode-independent — Firefox only re-reads them when the *templates* change (restart then)
- **Dark Reader** (addon@darkreader.org) follows the switcher via its automation (`mode: "system"`, `behavior: "Scheme"`): dark mode → `theme.mode=1` (dark scheme), light → `theme.mode=0` (light scheme; the `data-darkreader-scheme` attribute then reads `dimmed`, which just means "not dark"). Its popup label “Auto (the system is dark)” is generated from the extension's *on/off* state (`data.isEnabled`), not the system scheme — with `behavior: "Scheme"` it is permanently wrong; ignore it
- Chrome UI icons are pinned to the palette gray (`color8`) via the `--toolbarbutton-icon-fill` / `--icon-color` / `--menuitem-icon-fill` token family – Firefox's `light-dark()` defaults render them white in the dark mode
- **Firefox Sync is the theme saboteur** (verified empirically 2026-10): the synced add-on engine re-installs and re-activates store themes from other devices (e.g. the "Black" theme `{9b84b6b4-07c4-4b4b-ba21-394d86f6e9ee}`) minutes after every Firefox start. An active dark LWT theme forces the chrome AND `prefers-color-scheme` dark, so the `light-dark()` palettes get stuck on the dark half – theme switches look dead and restarts "don't help" because sync re-poisons within ~1 minute. The managed `user.js` block (switch-theme.sh) therefore pins `extensions.activeThemeID` AND disables theme prefs sync (`services.sync.prefs.sync.extensions.activeThemeID`, `browser.theme.*`, `ui.systemUsesDarkTheme`, …) plus `services.sync.engine.addons.enabled` (that engine is what drags the theme xpi back in). Don't remove those pins; and don't let the theme get selected again on other synced devices
- **`gsettings` flips are the only live lever for Firefox** – the deployed userChrome/userContent files are mode-independent; if Firefox ever looks stuck on one palette, first check that no dark LWT theme is active (about:addons → Themes) and that `org.gnome.desktop.interface color-scheme` actually holds the expected value

## Key Dotfile Locations

```
~/dotfiles/
├── config/                        # X11/config-agnostic files
│   └── .config/wal/
│       ├── colorschemes/dark/     # everforest.json, everforest_oled.json
│       └── templates/             # pywal templates (source of truth for styles)
├── config-wayland/
│   └── .config/
│       ├── hypr/                  # Hyprland config (hyprland.lua entry point)
│       │   └── conf/              # Lua modules (windowrules, binds, etc.)
│       └── waybar/
│           ├── config             # waybar JSON config (NOT auto-generated)
│           └── style.css          # DELETED from repo — auto-generated by pywal
└── scripts/
    ├── link-scripts.sh           # stow scripts/ into ~/.local/bin (run after adding a script)
    ├── cleanup.sh                # reclaim disk space (package caches, trash, journal)
    ├── gen-ff-theme.py           # render Firefox templates as light-dark() dual palettes
    └── reload_wal.sh              # regenerate pywal, deploy CSS, restart waybar+dunst
```

## Development Conventions

- **Never edit `~/.config/waybar/style.css` directly** — edit the pywal template at `~/.config/wal/templates/waybar-style.css.tpl` and run `reload_wal.sh`
- **Never edit `~/.config/dunst/dunstrc` directly** — edit `~/.config/wal/templates/dunstrc` and run `reload_wal.sh`
- **Window rules** use the Lua API (`hl.window_rule({ match = {…}, … })`) — the hyprlang `windowrulev2` syntax no longer exists in 0.56
- Dialog/popup windows (rename dialogs, confirm popups, …) should float via the rules in `windowrules.lua` — see the "Dialogs & popups" section there for the detection strategy
- Hyprland config is reloaded via `hyprctl reload`; it auto-reloads on file save
- `~/.config/hypr/` and `config-wayland/.config/hypr/` are hardlinked — edit either, both stay in sync
- **pywal must run with `-s` (skip terminal sequences)**: pywal's `sequences.send()` blindly writes escape codes to every `/dev/pts/[0-9]*` — a stale pty whose master is held but never read (leaked `adb shell` pty, closed VSCode terminal, …) has a full output queue and blocks `wal` forever (it hangs *before* exporting anything, so `~/.cache/wal` stays stale). Kitty recolors via `colors-kitty.conf` + SIGUSR1 instead. wpgtk (`setTheme` → `wpg -s`) has the same `pywal.sequences.send()` call — `~/.config/wpg/wpg.conf` needs `terminal = false`. To unblock a clogged pty: `python3 -c "import os,termios; fd=os.open('/dev/pts/N', os.O_WRONLY|os.O_NOCTTY); termios.tcflush(fd, termios.TCOFLUSH)"`
- **Scripts in `scripts/` are symlinked into `~/.local/bin`** via `link-scripts.sh` (GNU stow) — re-run it after adding/removing a script; never copy scripts into `/usr/local/bin`
- **GTK theming is pywal-driven, no oomox/themix** (removed from system) and switches **live**: GTK3 apps never re-read `~/.config/gtk-3.0/gtk.css` in a running process (parsed once at startup, then frozen), so the palette is deployed as a real theme `~/.themes/wal-dark` / `~/.themes/wal-light` (Adwaita gresource base + `colors-gtk.css` defines + `gtk-surfaces.css` widget rules) and flipped via `org.gnome.desktop.interface gtk-theme` — running GTK3 apps restyle instantly (`switch-theme.sh` hops through `Adwaita` first when the theme name is unchanged, since GSettings emits no notification for same-value writes). GTK4/libadwaita instead hot-reloads user CSS, so it keeps `~/.config/gtk-4.0/{colors.css,gtk.css}`. Qt5/Qt6 follow the GTK palette via `QT_QPA_PLATFORMTHEME=gtk3` in `hypr/conf/envs.lua`. GTK2 uses `~/.gtkrc-2.0.mine`. Don't reintroduce oomox/themix, qt5ct/qt6ct or kvantum, and never write `~/.config/gtk-3.0/gtk.css` again — a frozen stale copy overrides the live theme in running GTK3 apps
- **pywal templates are rendered with Python `str.format()`** — a bare literal `{`/`}` crashes `wal` with `KeyError`; either keep templates brace-free (defines only, static rules in `config/.config/gtk/gtk-surfaces.css`) or double every brace (`{{`/`}}`) as `waybar-style.css.tpl` and the `firefox-user*.css` templates do
- **Quickshell bar (`config-wayland/.config/quickshell/`) is palette-driven**: `theme.qml` (singleton `Theme`) reads `~/.cache/wal/colors.json` at runtime via `FileView` + `JsonAdapter` (with everforest_oled fallbacks) with `watchChanges: true` — colors hot-reload on theme switches, so `switch-theme.sh` must NOT restart quickshell (the bar disappearing makes windows reflow around the lost exclusive zone); it only starts the shell when it's dead (`scripts/restart_app quickshell`, which also strips the XWayland-HiDPI env). `hyprctl reload` still runs in switch-theme.sh (borders come from `styling.lua` reading `colors-hyprland.conf`). Geometry/fonts stay in `theme.qml`; all colors must go through `Theme.*` — no hardcoded hex in modules or overlays. `DesktopBackground.qml` (layer Background) paints the tiling gaps with `Theme.desktopBg` = `Theme.background` slightly HSL-lightened (only for non-black palettes — pitch-black OLED backgrounds stay `#000000`)
- `@define-color` redefinitions alone do NOT darken Adwaita (GTK resolves names inside the theme's provider) — the explicit widget rules in `gtk-surfaces.css` are what force `#000000`; verify with GTK3 `StyleContext.get_background_color` or a screenshot. The rules also mirror every surface/control selector with `:backdrop` (Adwaita grays unfocused windows via `.background:backdrop` → `#353535`, `treeview.view header button` → `#2d2d2d`, …) and reset `background-image` (Adwaita paints headerbars/buttons with gradients + `image()` that would sit on top of `background-color`) — keep focused and unfocused windows pixel-identical
- **HiDPI scaling for XWayland apps lives in `hypr/conf/envs.lua`** (`QT_SCREEN_SCALE_FACTORS`, `_JAVA_OPTIONS=-Dsun.java2d.uiScale=2`, `GDK_SCALE`): `xwayland.force_zero_scaling` + Xwayland's fake 96-DPI desktop make Qt/Java/GTK X11 apps render tiny, so they must scale themselves. Keep `QT_SCREEN_SCALE_FACTORS` in sync with the scales in `monitors.lua`. These vars leak into native-Wayland apps too and make them render oversized (double scaling) — `scripts/restart_app` strips them before launching; never start quickshell from a shell with them exported
- **Rofi gets a fake drop shadow from its theme** (`colors-rofi-dark.rasi` `#window` = translucent dark ring + blue-bordered `#mainbox`): Hyprland's `CHyprDropShadowDecoration` only renders for real windows, and rofi maps as a layer-shell surface (`-normal-window` is X11-only) — the layer `blur` rule makes the frosted background show through the ring
- GTK dark/light behavior was verified empirically (2026-10): GTK3 = live only on `gtk-theme` change, GTK4 = live on `gtk.css`/imports change (~2 s), Firefox = live on `color-scheme` change (resolves `light-dark()`), Firefox never reads GTK surface colors
- **hyproled** (OLED burn-in shader) is gated per theme: config in `config-wayland/.config/hypr/hyproled.conf` (`HYPROLED_DARK`/`HYPROLED_LIGHT` = `on|off`), enforced by the `hyproled.sh` wrapper – all hyproled call sites (listen.sh, prevent-oled-burnin.sh, hypridle.conf) must go through it. `switch-theme.sh` writes the active mode to `~/.cache/theme-mode`
- **VSCode themes are generated from the wal scheme files** (not pywal templates): `scripts/gen-vscode-theme.py` renders a managed extension `wal.wal-palette` (`~/.vscode/extensions/wal.wal-palette-*/`, also into `~/.vscode-oss/extensions`) with the themes "Wal OLED" (from `everforest_oled.json`) and "Wal Light" (from `everforest_light.json`) on every `switch-theme.sh` run; the script flips `workbench.colorTheme` (dark defaults to the Blackforest extension via `VSCODE_DARK_THEME`, light = "Wal Light"). Never edit the generated theme JSONs – extend the generator. Theme *switches* are live, but VSCode only re-reads theme *files* at startup (and needs one restart to first see the extension)
