# Hyprland Configuration Examples

This file contains practical examples and common configuration patterns.

## Complete Minimal Configuration

```conf
# ~/.config/hypr/hyprland.conf

# Monitor setup
monitor = ,preferred,auto,1

# Autostart
exec-once = waybar & dunst & hyprpaper

# Environment variables
env = XCURSOR_SIZE,24

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = true
    }
}

# General settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee)
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Decorations
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = true
    animation = windows, 1, 7, default
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Dwindle layout
dwindle {
    pseudotile = true
    preserve_split = true
}

# Master layout
master {
    new_is_master = true
}

# Key bindings
$mainMod = SUPER

bind = $mainMod, Return, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, dolphin
bind = $mainMod, V, togglefloating,
bind = $mainMod, F, fullscreen,
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# Move focus
bind = $mainMod, h, movefocus, l
bind = $mainMod, l, movefocus, r
bind = $mainMod, k, movefocus, u
bind = $mainMod, j, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# Move to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5

# Mouse bindings
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Window rules
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = float, class:^(blueman-manager)$
```

## Multi-Monitor Setup

```conf
# Primary monitor (center)
monitor = DP-1, 2560x1440@144, 1920x0, 1

# Left monitor (vertical)
monitor = HDMI-A-1, 1920x1080@60, 0x0, 1, transform, 1

# Right monitor
monitor = HDMI-A-2, 1920x1080@60, 4480x360, 1

# Laptop screen (below when docked)
monitor = eDP-1, 1920x1080@60, 1920x1440, 1

# Workspace bindings for monitors
workspace = 1, monitor:DP-1, default:true
workspace = 2, monitor:DP-1
workspace = 3, monitor:DP-1
workspace = 4, monitor:HDMI-A-1
workspace = 5, monitor:HDMI-A-1
workspace = 6, monitor:HDMI-A-2
```

## Gaming Configuration

```conf
# Disable VRR for most windows, enable for games
misc {
    vrr = 0
}

# Allow tearing for games (reduces latency)
general {
    allow_tearing = true
}

# Window rules for gaming
windowrulev2 = immediate, class:^(steam_app).*
windowrulev2 = immediate, class:^(lutris).*
windowrulev2 = fullscreen, class:^(steam_app).*

# Disable compositor effects for games
windowrulev2 = noinitialfocus, class:^(steam)$
windowrulev2 = noblur, class:^(steam_app).*
windowrulev2 = noanim, class:^(steam_app).*

# Inhibit idle when fullscreen
windowrulev2 = idleinhibit fullscreen, class:.*

# Dedicated gaming workspace
workspace = 9, monitor:DP-1, gapsin:0, gapsout:0, rounding:false
```

## Productivity Setup with Multiple Workspaces

```conf
# Workspace-specific rules
workspace = 1, monitor:DP-1, default:true  # Main workspace
workspace = 2, monitor:DP-1  # Browser
workspace = 3, monitor:DP-1  # Development
workspace = 4, monitor:DP-1  # Communication

# Application workspace assignments
windowrulev2 = workspace 2, class:^(firefox)$
windowrulev2 = workspace 2, class:^(chromium)$
windowrulev2 = workspace 3, class:^(Code)$
windowrulev2 = workspace 3, class:^(jetbrains-.*)$
windowrulev2 = workspace 4 silent, class:^(discord)$
windowrulev2 = workspace 4 silent, class:^(Slack)$

# Open apps on startup in specific workspaces
exec-once = [workspace 2 silent] firefox
exec-once = [workspace 3 silent] code
exec-once = [workspace 4 silent] discord

# Quick workspace navigation
bind = $mainMod, TAB, workspace, previous
bind = $mainMod SHIFT, TAB, workspace, previous

# Move window between monitors
bind = $mainMod CTRL, h, movecurrentworkspacetomonitor, l
bind = $mainMod CTRL, l, movecurrentworkspacetomonitor, r
```

## Laptop-Specific Configuration

```conf
# Touchpad configuration
input {
    touchpad {
        natural_scroll = true
        tap-to-click = true
        drag_lock = false
        disable_while_typing = true
        clickfinger_behavior = true
        middle_button_emulation = true
        scroll_factor = 0.5
    }
}

# Gestures
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
    workspace_swipe_invert = true
    workspace_swipe_create_new = true
}

# Battery-saving settings
misc {
    vfr = true  # Variable framerate when idle
}

decoration {
    blur {
        enabled = true
        size = 2  # Smaller blur for battery
        passes = 1
    }
}

# Brightness and volume keys
bindl = , XF86MonBrightnessUp, exec, brightnessctl set 10%+
bindl = , XF86MonBrightnessDown, exec, brightnessctl set 10%-
bindl = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindl = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Auto-rotate screen (for 2-in-1 laptops)
exec-once = iio-hyprland
```

## Tiling Window Manager Workflow

```conf
# Advanced window management
bind = $mainMod, Space, cyclenext,
bind = $mainMod SHIFT, Space, cyclenext, prev

# Resize windows
bind = $mainMod ALT, h, resizeactive, -40 0
bind = $mainMod ALT, l, resizeactive, 40 0
bind = $mainMod ALT, k, resizeactive, 0 -40
bind = $mainMod ALT, j, resizeactive, 0 40

# Move windows
bind = $mainMod SHIFT, h, movewindow, l
bind = $mainMod SHIFT, l, movewindow, r
bind = $mainMod SHIFT, k, movewindow, u
bind = $mainMod SHIFT, j, movewindow, d

# Window groups (tabbed containers)
bind = $mainMod, G, togglegroup
bind = $mainMod, TAB, changegroupactive, f
bind = $mainMod SHIFT, TAB, changegroupactive, b

# Scratchpad
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Center floating window
bind = $mainMod, C, centerwindow

# Pin window (show on all workspaces)
bind = $mainMod, Y, pin
```

## NVIDIA GPU Configuration

```conf
# Environment variables for NVIDIA
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
env = NVD_BACKEND,direct

# Cursor fix
misc {
    no_direct_scanout = true
}

# Explicit sync (NVIDIA 545.29.06+)
render {
    explicit_sync = 2  # 0 = off, 1 = on, 2 = auto
    explicit_sync_kms = 2
}
```

## Rice (Beautiful Desktop) Configuration

```conf
# Beautiful gaps and borders
general {
    gaps_in = 8
    gaps_out = 16
    border_size = 3
    
    # Gradient borders
    col.active_border = rgba(ca9ee6ff) rgba(f2d5cfff) 45deg
    col.inactive_border = rgba(232634aa)
    
    layout = dwindle
}

# Smooth animations
bezier = wind, 0.05, 0.9, 0.1, 1.05
bezier = winIn, 0.1, 1.1, 0.1, 1.1
bezier = winOut, 0.3, -0.3, 0, 1
bezier = liner, 1, 1, 1, 1

animations {
    enabled = true
    
    animation = windows, 1, 6, wind, slide
    animation = windowsIn, 1, 6, winIn, slide
    animation = windowsOut, 1, 5, winOut, slide
    animation = windowsMove, 1, 5, wind, slide
    
    animation = border, 1, 1, liner
    animation = borderangle, 1, 30, liner, loop
    
    animation = fade, 1, 10, default
    animation = workspaces, 1, 5, wind
}

# Beautiful decorations
decoration {
    rounding = 12
    
    active_opacity = 1.0
    inactive_opacity = 0.85
    
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = true
        xray = false
        ignore_opacity = true
        noise = 0.01
        contrast = 1.0
        brightness = 1.0
        vibrancy = 0.2
    }
    
    drop_shadow = true
    shadow_range = 20
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
    col.shadow_inactive = rgba(1a1a1a99)
    
    dim_inactive = true
    dim_strength = 0.1
}

# Layer rules for bars and launchers
layerrule = blur, waybar
layerrule = blur, rofi
layerrule = ignorezero, waybar
```

## Application-Specific Rules

```conf
# Firefox Picture-in-Picture
windowrulev2 = float, title:^(Picture-in-Picture)$
windowrulev2 = pin, title:^(Picture-in-Picture)$
windowrulev2 = size 640 360, title:^(Picture-in-Picture)$
windowrulev2 = move 100%-660 100%-400, title:^(Picture-in-Picture)$

# File pickers
windowrulev2 = float, title:^(Open File)$
windowrulev2 = float, title:^(Save File)$
windowrulev2 = size 800 600, title:^(Open File)$
windowrulev2 = center, title:^(Open File)$

# Password managers
windowrulev2 = float, class:^(1Password)$
windowrulev2 = float, class:^(Bitwarden)$
windowrulev2 = center, class:^(1Password)$

# Image viewers
windowrulev2 = float, class:^(imv)$
windowrulev2 = float, class:^(feh)$
windowrulev2 = center, class:^(imv)$

# Terminal dropdowns
windowrulev2 = float, class:^(dropdown)$
windowrulev2 = size 80% 60%, class:^(dropdown)$
windowrulev2 = move 10% 5%, class:^(dropdown)$
windowrulev2 = workspace special:dropdown silent, class:^(dropdown)$

# Steam
windowrulev2 = workspace 8 silent, class:^(steam)$, title:^(Steam)$
windowrulev2 = float, class:^(steam)$, title:^(Friends List)$
windowrulev2 = float, class:^(steam)$, title:^(Steam Settings)$

# Jetbrains IDEs
windowrulev2 = float, class:^(jetbrains-.*)$, title:^(win.*)$
windowrulev2 = center, class:^(jetbrains-.*)$, title:^(win.*)$
```

## Modular Configuration

Split your configuration into multiple files:

### Main config (`~/.config/hypr/hyprland.conf`)
```conf
# Source other configs
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/autostart.conf
source = ~/.config/hypr/env.conf
source = ~/.config/hypr/input.conf
source = ~/.config/hypr/general.conf
source = ~/.config/hypr/decoration.conf
source = ~/.config/hypr/animations.conf
source = ~/.config/hypr/keybinds.conf
source = ~/.config/hypr/windowrules.conf
```

### Monitors (`monitors.conf`)
```conf
monitor = DP-1, 2560x1440@144, 0x0, 1
monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
```

### Autostart (`autostart.conf`)
```conf
exec-once = waybar
exec-once = dunst
exec-once = hyprpaper
```

### Keybinds (`keybinds.conf`)
```conf
$mainMod = SUPER
bind = $mainMod, Return, exec, kitty
# ... all your keybinds
```

This modular approach makes it easier to manage and modify specific aspects of your configuration.
