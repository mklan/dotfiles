-- Environment variables

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORM", "wayland")
-- Qt5 + Qt6 follow the GTK palette (pitch black) via the stock "gtk3"
-- platform theme shipped with qt5-base/qt6-base. No qt5ct/qt6ct/kvantum needed.
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Monitor scaling envs (from monitors.conf)
hl.env("GDK_SCALE", "2")

-- HiDPI scaling for XWayland apps (Qt: Eden/emulator AppImages, Java:
-- JDownloader & friends, …). Xwayland fakes a 2880x1800 desktop at 96 DPI and
-- xwayland.force_zero_scaling stops the compositor from upscaling those
-- windows, so the apps must scale themselves:
--   * Qt5/Qt6: per-screen factors mirroring monitors.lua. WARNING: Qt honors
--     this on Wayland too and native-Wayland apps (quickshell, …) then render
--     oversized (scaled by us AND by the compositor). quickshell is launched
--     via scripts/restart_app which strips these vars — don't start it from a
--     shell with them exported.
--   * Java AWT/Swing: classic sun.java2d.uiScale (AWT sees 96 DPI).
--   * GTK X11: already covered by GDK_SCALE above.
-- Re-login (or restart the launcher/terminal) so new apps pick these up.
hl.env("QT_SCREEN_SCALE_FACTORS", "eDP-1=2;DP-1=1.6;DP-2=1.6;HDMI-A-1=2.5")
hl.env("_JAVA_OPTIONS", "-Dsun.java2d.uiScale=2")
