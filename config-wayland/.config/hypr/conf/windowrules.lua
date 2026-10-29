-- Window Rules for Hyprland 0.55+ Lua

-- ── Float rules ──

hl.window_rule({
    match = { class = "keepassxc" },
    float = true,
    move  = {"monitor_w - 600", "monitor_h - 400"},
})

hl.window_rule({
    match = { title = "File Operation Progress" },
    float = true,
})

hl.window_rule({
    match = { class = "Authy" },
    move  = {"monitor_w * 0.83", "monitor_h * 0.5"},
})

hl.window_rule({
    match = { class = "pavucontrol" },
    float = true,
})

hl.window_rule({
    match = { class = "blueman-manager" },
    float = true,
})

hl.window_rule({
    match = { class = "org.kde.polkit-kde-authentication-agent-1" },
    float = true,
})

-- ── File dialogs ──

hl.window_rule({
    match  = { class = "xdg-desktop-portal-gtk" },
    float  = true,
    size   = {"monitor_w * 0.7", "monitor_h * 0.7"},
    center = true,
})

hl.window_rule({
    match = { title = "Enter name of file to save to…" },
    float = true,
    size  = {720, 380},
})

-- ── Dialogs & popups ──
--
-- How detection works (Hyprland 0.56 Lua API):
--   * match values are ECMAScript regexes matched against the ENTIRE string
--     (full-match semantics) — wrap in ".*...*" for substring matching.
--   * `modal = true` catches toolkits that announce modality over the protocol
--     (GTK4, Qt5/6, Electron). GTK3 (Thunar & friends) never sends set_modal,
--     so its dialogs have to be caught via `initial_title`.
--   * `initial_title` is frozen at map time, so a later title change (e.g. a
--     browser tab loading a page called "Rename …") cannot trigger a rule.
--   * A `float` rule applied at map time keeps the window's natural size,
--     so popped-up dialogs stay small instead of filling a tile.

-- Generic: modal dialogs (rename/confirm/save popups of GTK4/Qt/Electron apps)
hl.window_rule({
    name   = "modal-dialogs",
    match  = { modal = true },
    float  = true,
    center = true,
})

-- Generic: windows that open with a dialog-like title (covers GTK3 dialogs)
local dialog_title = [[.*(]] .. table.concat({
    [[Rename ".*"]],
    [[Bulk Rename.*]],
    [[Rename Multiple Files]],
    [[Rename Launcher Options]],
    [[.* Properties]],
    [[Properties of .*]],
    [[Save As]],
    [[Save File]],
    [[Open File]],
    [[Choose (a |the )?([Ff]ile|[Ff]older|[Dd]irectory|[Ii]mage|[Cc]olor)]],
    [[Select (a |the )?([Ff]ile|[Ff]older|[Dd]irectory|[Ii]mage)]],
    [[Are you sure.*]],
    [[Confirm (Delete|Removal|Action|[Oo]verwrite)]],
    [[Authentication( Required)?]],
    [[Enter (your )?[Pp]ass(word|phrase)]],
    [[File Operation.*]],
    [[(Warning|Error|Question|Information)( - .*)?]],
}, "|") .. [[).*]]

hl.window_rule({
    name   = "dialog-titles",
    match  = { initial_title = dialog_title },
    float  = true,
    center = true,
})

-- Thunar's bulk renamer is a dialog but requests a huge natural size (~718x852).
-- Float it explicitly small — this is the "right click → rename" popup.
hl.window_rule({
    name   = "thunar-bulk-rename",
    match  = { class = "Thunar", initial_title = "Bulk Rename.*" },
    float  = true,
    size   = {720, 460},
    center = true,
})

-- ── Rofi & Wlogout ──

hl.window_rule({
    match        = { class = "rofi" },
    float        = true,
    stay_focused = true,
    animation    = "slide",
})

hl.window_rule({
    match   = { class = "Wlogout" },
    no_anim = true,
})

hl.layer_rule({
    match = { namespace = "rofi" },
    blur  = true,
})

hl.layer_rule({
    match = { namespace = "waybar" },
    blur  = true,
})

hl.layer_rule({
    match = { namespace = "notifications" },
    blur  = true,
})

-- ── Assistant ──

hl.window_rule({
    match          = { class = "assistant" },
    float          = true,
    size           = {"monitor_w * 0.5", "monitor_h * 0.5"},
    move           = {"monitor_w * 0.25", 32},
    workspace      = "special:assistant silent",
    suppress_event = "fullscreen",
})

-- ── Picture-in-Picture ──

hl.window_rule({
    match = { title = "Picture-in-Picture" },
    float = true,
    size  = {640, 360},
    move  = {"monitor_w - 680", "monitor_h - 400"},
    pin   = true,
})

-- ── Tiling: ignore maximize requests from apps ──
--
-- kitty (remember_window_size) restores its saved window state on startup and
-- sends a maximize request; kitty re-saves that state on exit, so once
-- "window-state: maximized" is in ~/.cache/kitty/main.json it sticks forever.
-- Hyprland honors client maximize requests, so the window filled the whole
-- work area instead of tiling and covered the other tiled windows.  Ignore
-- maximize events from clients — compositor-initiated maximize and the
-- fullscreen dispatcher (HYPER+space) are unaffected.

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- ── Idle inhibit for fullscreen ──

hl.window_rule({
    match        = { fullscreen = true },
    idle_inhibit = "fullscreen",
})

-- ── pypr drop-term scratchpad ──

hl.window_rule({
    match = { class = "kitty-dropterm" },
    float = true,
    pin   = true,
})
