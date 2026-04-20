# Hyprland Configuration Reference

This reference covers the most common Hyprland configuration variables, patterns, and syntax.

## Configuration File Location

- Main config: `~/.config/hypr/hyprland.conf`
- Can split into multiple files using `source = /path/to/file.conf`

## Core Syntax

```conf
# Comments start with #
keyword = value
section {
    variable = value
}
```

## Monitor Configuration

```conf
# Syntax: monitor = name, resolution@refresh, position, scale
monitor = DP-1, 2560x1440@144, 0x0, 1
monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
monitor = ,preferred, auto, 1  # Catch-all for other monitors

# Disable a monitor
monitor = HDMI-A-1, disable

# High DPI monitor
monitor = eDP-1, 3840x2160@60, 0x0, 2
```

## General Settings

```conf
general {
    # Gaps
    gaps_in = 5          # Gaps between windows
    gaps_out = 10        # Gaps between windows and monitor edges
    gaps_workspaces = 50 # Gaps between workspaces
    
    # Borders
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    
    # Layouts
    layout = dwindle  # or master
    
    # Mouse
    resize_on_border = true
    extend_border_grab_area = 15
    hover_icon_on_border = true
    
    # Window behavior
    allow_tearing = false
    no_focus_fallback = false
}
```

## Decoration Settings

```conf
decoration {
    # Rounding
    rounding = 10
    
    # Active/Inactive opacity
    active_opacity = 1.0
    inactive_opacity = 0.9
    fullscreen_opacity = 1.0
    
    # Blur
    blur {
        enabled = true
        size = 3
        passes = 1
        new_optimizations = true
        xray = false
        ignore_opacity = false
        noise = 0.0117
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.0
        popups = false
        popups_ignorealpha = 0.2
    }
    
    # Shadow
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
    shadow_offset = 0 0
    
    # Dimming
    dim_inactive = false
    dim_strength = 0.5
    dim_special = 0.2
    dim_around = 0.4
}
```

## Animation Settings

```conf
animations {
    enabled = true
    
    # Animation curves: linear, easeIn, easeOut, easeInOut, 
    #                   easeInSine, easeOutSine, easeInOutSine,
    #                   easeInQuad, easeOutQuad, easeInOutQuad,
    #                   easeInCubic, easeOutCubic, easeInOutCubic,
    #                   easeInQuart, easeOutQuart, easeInOutQuart,
    #                   easeInQuint, easeOutQuint, easeInOutQuint,
    #                   easeInExpo, easeOutExpo, easeInOutExpo,
    #                   easeInCirc, easeOutCirc, easeInOutCirc,
    #                   easeInBack, easeOutBack, easeInOutBack
    
    # Bezier curves (custom)
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    bezier = linear, 0.0, 0.0, 1.0, 1.0
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    
    # Syntax: animation = NAME, ONOFF, SPEED, CURVE [,STYLE]
    animation = windows, 1, 7, myBezier
    animation = windowsIn, 1, 7, winIn, popin 80%
    animation = windowsOut, 1, 7, winOut, slide
    animation = windowsMove, 1, 7, wind, slide
    
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    
    animation = fade, 1, 7, default
    animation = fadeIn, 1, 7, default
    animation = fadeOut, 1, 7, default
    animation = fadeSwitch, 1, 7, default
    animation = fadeShadow, 1, 7, default
    animation = fadeDim, 1, 7, default
    
    animation = workspaces, 1, 6, default
    animation = specialWorkspace, 1, 6, default, slidevert
}
```

## Input Settings

```conf
input {
    # Keyboard
    kb_layout = us
    kb_variant = 
    kb_model =
    kb_options = caps:escape  # Example: caps lock as escape
    kb_rules =
    repeat_rate = 25
    repeat_delay = 600
    numlock_by_default = false
    
    # Mouse
    sensitivity = 0.0  # -1.0 to 1.0, 0 means no modification
    accel_profile = flat  # flat, adaptive
    force_no_accel = false
    left_handed = false
    scroll_method = 2fg  # 2fg, edge, on_button_down, no_scroll
    scroll_button = 0  # 0 disables
    natural_scroll = false
    
    # Touchpad
    touchpad {
        disable_while_typing = true
        natural_scroll = true
        scroll_factor = 1.0
        middle_button_emulation = false
        tap_button_map = lrm  # lrm, lmr
        clickfinger_behavior = false
        tap-to-click = true
        drag_lock = false
        tap-and-drag = true
    }
    
    # Follow mouse focus
    follow_mouse = 1  # 0 disabled, 1 always, 2 only when crossing border, 3 only on click
    float_switch_override_focus = 1
}
```

## Gestures

```conf
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
    workspace_swipe_invert = true
    workspace_swipe_min_speed_to_force = 30
    workspace_swipe_cancel_ratio = 0.5
    workspace_swipe_create_new = true
    workspace_swipe_forever = false
    workspace_swipe_direction_lock = true
    workspace_swipe_direction_lock_threshold = 10
}
```

## Miscellaneous Settings

```conf
misc {
    disable_hyprland_logo = false
    disable_splash_rendering = false
    vfr = true  # Variable refresh rate
    vrr = 0  # Variable Refresh Rate: 0 (off), 1 (on), 2 (fullscreen only)
    mouse_move_enables_dpms = false
    key_press_enables_dpms = false
    always_follow_on_dnd = true
    layers_hog_keyboard_focus = true
    animate_manual_resizes = false
    animate_mouse_windowdragging = false
    disable_autoreload = false
    enable_swallow = false
    swallow_regex = ^(kitty)$
    focus_on_activate = false
    no_direct_scanout = true
    hide_cursor_on_touch = true
    mouse_move_focuses_monitor = true
    suppress_portal_warnings = false
    render_ahead_of_time = false
    render_ahead_safezone = 1
    allow_session_lock_restore = false
    background_color = 0x111111
    close_special_on_empty = true
    new_window_takes_over_fullscreen = 0
}
```

## Keybindings

```conf
# Syntax: bind = MODIFIERS, key, dispatcher, params
# Modifiers: SUPER, CTRL, ALT, SHIFT (can combine with +)

# Basic binds
bind = SUPER, Return, exec, kitty
bind = SUPER, Q, killactive,
bind = SUPER, M, exit,
bind = SUPER, E, exec, dolphin
bind = SUPER, V, togglefloating,
bind = SUPER, P, pseudo,  # dwindle
bind = SUPER, J, togglesplit,  # dwindle
bind = SUPER, F, fullscreen, 0  # 0 for real fullscreen, 1 for maximize

# Move focus with SUPER + arrow keys
bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d

# Move focus with SUPER + vim keys
bind = SUPER, h, movefocus, l
bind = SUPER, l, movefocus, r
bind = SUPER, k, movefocus, u
bind = SUPER, j, movefocus, d

# Switch workspaces with SUPER + [0-9]
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
# ... etc

# Move active window to a workspace with SUPER + SHIFT + [0-9]
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
# ... etc

# Scroll through existing workspaces with SUPER + scroll
bind = SUPER, mouse_down, workspace, e+1
bind = SUPER, mouse_up, workspace, e-1

# Move/resize windows with SUPER + LMB/RMB and dragging
bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow

# Special workspace (scratchpad)
bind = SUPER, S, togglespecialworkspace, magic
bind = SUPER SHIFT, S, movetoworkspace, special:magic

# Global binds (work even when locked or in another app)
bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindl = , XF86AudioPlay, exec, playerctl play-pause
bindl = , XF86AudioNext, exec, playerctl next
bindl = , XF86AudioPrev, exec, playerctl previous

# Locked binds (work when screen is locked)
bindl = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindl = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+

# Release binds (triggered on key release)
bindr = SUPER, SUPER_L, exec, pkill rofi || rofi -show drun

# Repeat binds (repeat while held)
binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
```

## Window Rules

```conf
# Syntax: windowrule = RULE, WINDOW
# OR: windowrulev2 = RULE, PROPERTY, VALUE

# By class
windowrule = float, ^(kitty)$
windowrule = opacity 0.8 override, ^(kitty)$

# By title
windowrulev2 = float, title:^(Picture-in-Picture)$

# Multiple conditions
windowrulev2 = float, class:^(pavucontrol)$, title:^(Volume Control)$

# Common rules
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = float, class:^(blueman-manager)$
windowrulev2 = float, class:^(nm-connection-editor)$
windowrulev2 = float, title:^(Authentication Required)$

# Workspace rules
windowrulev2 = workspace 1, class:^(firefox)$
windowrulev2 = workspace 2, class:^(code)$
windowrulev2 = workspace 3 silent, class:^(discord)$

# Opacity
windowrulev2 = opacity 0.9 0.7, class:^(Code)$

# Size and position
windowrulev2 = size 800 600, class:^(pavucontrol)$
windowrulev2 = move 100 100, class:^(pavucontrol)$
windowrulev2 = center, class:^(pavucontrol)$

# Pinning (visible on all workspaces)
windowrulev2 = pin, class:^(firefox)$, title:^(Picture-in-Picture)$

# No animations
windowrulev2 = noanim, class:^(wlogout)$

# Fullscreen behavior
windowrulev2 = idleinhibit fullscreen, class:.*
```

## Layer Rules

```conf
# Syntax: layerrule = RULE, LAYER

# Common layers: background, bottom, top, overlay

layerrule = blur, waybar
layerrule = blur, rofi
layerrule = ignorezero, waybar
layerrule = ignorezero, rofi
```

## Workspace Rules

```conf
# Syntax: workspace = ID, RULES

workspace = 1, monitor:DP-1, default:true
workspace = 2, monitor:DP-1
workspace = 3, monitor:HDMI-A-1

workspace = special:scratchpad, gapsout:50, gapsin:20, on-created-empty:kitty
```

## Autostart

```conf
# Execute once at launch
exec-once = waybar
exec-once = dunst
exec-once = hyprpaper
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Execute on every reload
exec = pkill waybar; waybar
```

## Environment Variables

```conf
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt6ct
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
```

## Sourcing Files

```conf
# Source additional config files
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/keybinds.conf
source = ~/.config/hypr/colors.conf
```

## Dispatchers Reference

Common dispatchers for keybinds:

- `exec, [command]` - Execute a command
- `killactive` - Close active window
- `exit` - Exit Hyprland
- `togglefloating` - Toggle floating for active window
- `fullscreen, [0/1]` - Toggle fullscreen (0=real, 1=maximize)
- `workspace, [id]` - Switch to workspace
- `movetoworkspace, [id]` - Move window to workspace
- `movefocus, [l/r/u/d]` - Move focus
- `movewindow, [l/r/u/d]` - Move window
- `resizeactive, [x] [y]` - Resize active window
- `pseudo` - Toggle pseudo-tiling (dwindle)
- `togglesplit` - Toggle split (dwindle)
- `togglespecialworkspace, [name]` - Toggle special workspace
- `cyclenext` - Focus next window
- `centerwindow` - Center floating window
- `pin` - Pin window to all workspaces
- `lockactivegroup` - Lock group
- `togglegroup` - Toggle group

## Layout-Specific Settings

### Dwindle Layout

```conf
dwindle {
    pseudotile = true
    preserve_split = true
    force_split = 0  # 0 follows mouse, 1 left/top, 2 right/bottom
    split_width_multiplier = 1.0
    no_gaps_when_only = false
    use_active_for_splits = true
    default_split_ratio = 1.0
}
```

### Master Layout

```conf
master {
    new_on_top = false
    new_is_master = true
    mfact = 0.5
    orientation = left  # left, right, top, bottom, center
    inherit_fullscreen = true
    always_center_master = false
    smart_resizing = true
    drop_at_cursor = true
}
```

## Debug and Development

```conf
debug {
    overlay = false
    damage_blink = false
    disable_logs = false
    disable_time = true
    damage_tracking = 2  # 0 = none, 1 = monitor, 2 = full
}
```
