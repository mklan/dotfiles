-- Keybindings

local HYPER  = "CTRL+SUPER+ALT"
local CONFIG = "~/.config/hypr"
local HOME   = os.getenv("HOME")

-- ── Window management ──────────────────────────────────────────────────────────

hl.bind(HYPER .. " + space", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + D",          hl.dsp.exec_cmd("killall rofi || rofi -show run"))
hl.bind(HYPER .. " + return", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + Q",          hl.dsp.window.close())
hl.bind("SUPER + C",          hl.dsp.exec_cmd("vscode-projects ~/projects"))

-- Toggle float + resize + center
hl.bind("SUPER + space", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ x = 960, y = 540 }))
    hl.dispatch(hl.dsp.window.center())
end)

hl.bind("SUPER + L", hl.dsp.exec_cmd(CONFIG .. "/scripts/lock.sh"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(HYPER .. " + K", hl.dsp.exec_cmd("deno run --allow-all " .. CONFIG .. "/scripts/active_window_pip.ts"))

-- ── Gap controls ───────────────────────────────────────────────────────────────

hl.bind(HYPER .. " + plus",  hl.dsp.exec_cmd(CONFIG .. "/scripts/gap.sh -2"), { repeating = true })
hl.bind(HYPER .. " + minus", hl.dsp.exec_cmd(CONFIG .. "/scripts/gap.sh 2"),  { repeating = true })
hl.bind(HYPER .. " + M",     hl.dsp.exec_cmd(CONFIG .. "/scripts/set_gap.sh 2"), { repeating = true })

-- ── DPMS toggle ────────────────────────────────────────────────────────────────

hl.bind(HYPER .. " + O", hl.dsp.exec_cmd("hyprctl dispatch dpms off && sleep 1 && hyprctl dispatch dpms on"))

-- ── Focus movement ─────────────────────────────────────────────────────────────

hl.bind(HYPER .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(HYPER .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(HYPER .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(HYPER .. " + down",  hl.dsp.focus({ direction = "d" }))

-- ── Window movement ────────────────────────────────────────────────────────────

hl.bind("CTRL+SUPER + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind("CTRL+SUPER + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("CTRL+SUPER + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind("CTRL+SUPER + down",  hl.dsp.window.move({ direction = "d" }))

-- ── Window resizing (native dispatcher)



hl.bind("SUPER+ALT + left",  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind("SUPER+ALT + right", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind("SUPER+ALT + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind("SUPER+ALT + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })
-- ── Mouse drag: move / resize ──────────────────────────────────────────────────

hl.bind("SUPER + mouse:272", hl.dsp.window.drag({ action = "move" }),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.drag({ action = "resize" }), { mouse = true })

-- ── Workspace switching (native dispatch — no external script) ─────────────────

for i = 1, 9 do
    hl.bind("CTRL + " .. i, hl.dsp.focus({ workspace = i }))
end
hl.bind("CTRL + 0", hl.dsp.focus({ workspace = 10 }))

-- ── Workspace cycling

hl.bind("SUPER + Tab",       hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER+SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))

-- ── Move window to workspace (silent)

for i = 1, 9 do
    hl.bind(HYPER .. " + " .. i, hl.dsp.window.move({ workspace = i, silent = true }))
end
hl.bind(HYPER .. " + 0", hl.dsp.window.move({ workspace = 10, silent = true }))

-- ── Reload ─────────────────────────────────────────────────────────────────────

hl.bind("SHIFT+ALT + R", hl.dsp.exec_cmd("hyprctl reload && notify-send 'reload hyprland'"))

-- ── App launchers ──────────────────────────────────────────────────────────────

hl.bind(HYPER .. " + F", hl.dsp.exec_cmd(CONFIG .. "/scripts/focus-or-open-firefox.sh"))
hl.bind(HYPER .. " + P", hl.dsp.exec_cmd(CONFIG .. "/scripts/focus-or-open-firefox.sh --private"))

-- ── Audio ──────────────────────────────────────────────────────────────────────

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 1"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 1"), { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pamixer --toggle-mute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(CONFIG .. "/scripts/mic-control.ts"), { locked = true })

-- ── Brightness ─────────────────────────────────────────────────────────────────

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(HOME .. "/dotfiles/scripts/brightness.sh up"),   { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(HOME .. "/dotfiles/scripts/brightness.sh down"), { repeating = true, locked = true })
hl.bind(HYPER .. " + XF86MonBrightnessUp",   hl.dsp.exec_cmd("light -S 100"), { locked = true })
hl.bind(HYPER .. " + XF86MonBrightnessDown", hl.dsp.exec_cmd("light -S 0.5"), { locked = true })

-- ── Voxtype push-to-talk ─────────────────────────────────────────────────────
-- Hold SUPER+V to record, release to transcribe+type. The voxtype daemon
-- (systemd user service, enabled at login) does the recording/typing.

hl.bind("SUPER + V", hl.dsp.exec_cmd("voxtype record start"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("voxtype record stop"), { release = true })

-- ── Pypr / drop-term ───────────────────────────────────────────────────────────

hl.bind("SUPER + A", hl.dsp.exec_cmd(CONFIG .. "/scripts/pypr-toggle-term.sh"))

-- ── Assistant special workspace ────────────────────────────────────────────────

hl.bind("SUPER + X",  hl.dsp.workspace.toggle_special("assistant"))
hl.bind("SUPER + Y",  hl.dsp.exec_cmd("pypr toggle_special assistant"))
hl.bind("ALT + X",    hl.dsp.exec_cmd(CONFIG .. "/scripts/spawn_assistant.sh"))
