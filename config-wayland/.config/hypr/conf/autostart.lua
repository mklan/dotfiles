-- Autostart commands

-- exec-once equivalent: runs only at Hyprland start, not on config reload
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/xdg.sh")
    hl.exec_cmd("~/.config/hypr/scripts/battery-monitor.sh")

    hl.exec_cmd("systemctl --user restart dbus")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")

    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    hl.exec_cmd("dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus")

    hl.exec_cmd("~/.config/hypr/scripts/listener/listen.sh")

    -- pywal theme (start waybar and set colors)
    hl.exec_cmd("~/dotfiles/scripts/switch-theme.sh dark")

    hl.exec_cmd("/usr/lib/at-spi-bus-launcher --exit-with-session")
    -- Run hypridle via its systemd unit (Restart=on-failure) — a bare exec
    -- dies silently when the user dbus is restarted (hypridle SIGABRTs).
    hl.exec_cmd("systemctl --user start hypridle")
    hl.exec_cmd("pypr")
    hl.exec_cmd("nm-applet")
    -- voxtype push-to-talk daemon (SUPER+V); systemd keeps it alive
    hl.exec_cmd("systemctl --user start voxtype.service")

    hl.exec_cmd("redshift-gtk -l 48.20849:16.37208")
    hl.exec_cmd("~/.config/hypr/scripts/tools/notify-rest/index.ts")

    -- Quickshell bar
    hl.exec_cmd("~/dotfiles/scripts/restart_app quickshell")
end)

-- exec equivalent: runs on every config reload (startup + reload)
hl.exec_cmd("setxkbmap de")
hl.exec_cmd("~/.config/hypr/scripts/prevent-oled-burnin.sh")
hl.exec_cmd("~/.config/hypr/scripts/spawn_assistant.sh")
hl.exec_cmd("/usr/bin/nmcli radio wifi on")
