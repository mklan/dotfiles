-- Animations — enabled so curves/styles are loaded, but window speeds are near-instant (0.1ds).
-- The pypr scratchpad script temporarily bumps the speed for smooth sliding.

hl.config({ animations = { enabled = true } })

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })

-- Near-instant by default — normal spawning stays fast
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 0.1, bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 0.1, bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 0.1, bezier = "easeOutQuint" })
hl.animation({ leaf = "fade",         enabled = false })
hl.animation({ leaf = "border",       enabled = false })
hl.animation({ leaf = "layers",       enabled = false })
hl.animation({ leaf = "workspaces",   enabled = false })
hl.animation({ leaf = "zoomFactor",   enabled = false })
