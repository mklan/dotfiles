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
    size           = {"monitor_w * 0.8", "monitor_h * 0.7"},
    move           = {"monitor_w * 0.1", "monitor_h * 0.25"},
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
