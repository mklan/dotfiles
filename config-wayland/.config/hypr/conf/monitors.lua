-- Monitor configuration
-- Laptop display
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1800@60",
    position = "0x0",
    scale    = 2,
})

-- External monitors
hl.monitor({
    output   = "DP-1",
    mode     = "3840x2160@60",
    position = "auto-left",
    scale    = 1.6,
})

hl.monitor({
    output   = "DP-2",
    mode     = "3840x2160@60",
    position = "auto-left",
    scale    = 1.6,
})

-- HDMI 4K
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "3840x2160@60",
    position = "auto-up",
    scale    = 2.5,
})

-- XWayland
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
