-- Input configuration

hl.config({
    input = {
        kb_layout     = "de",
        repeat_rate   = 25,
        follow_mouse  = 1,
        natural_scroll = 1,
        touchpad = {
            natural_scroll = 1,
        },
    },
})

-- Trackpoint sensitivity
hl.device({
    name        = "tpps/2-synaptics-trackpoint",
    sensitivity = -0.2,
})

hl.device({
    name        = "tpps/2-elan-trackpoint",
    sensitivity = -0.2,
})
