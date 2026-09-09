-- Styling: general, decoration, misc, ecosystem
-- Border colors read from pywal cache at config load time.

local function wal_color(name)
    local f = io.open(os.getenv("HOME") .. "/.cache/wal/colors-hyprland.conf", "r")
    if not f then return "rgb(ffffff)" end
    for line in f:lines() do
        local val = line:match("^%$" .. name .. "%s*=%s*(.-)%s*$")
        if val then f:close(); return val end
    end
    f:close()
    return "rgb(ffffff)"
end

local active_border   = wal_color("color5")
local inactive_border = wal_color("color6")

hl.config({
    general = {
        gaps_in          = 3,
        gaps_out         = 2,
        border_size      = 1,
        resize_on_border = true,
        col = {
            active_border   = active_border,
            inactive_border = inactive_border,
        },
    },

    decoration = {
        rounding     = 0,
        dim_inactive = false,
        dim_strength = 0.5,
        blur = {
            enabled  = false,
            size     = 8,
            passes   = 2,
            noise    = 0,
            contrast = 1,
        },
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        focus_on_activate        = true,
        background_color         = "0x000000",
    },

    ecosystem = {
        no_update_news = true,
    },
})
