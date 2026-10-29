import QtQuick
import Quickshell
import Quickshell.Wayland

// Solid desktop background ("wallpaper") – slightly lighter than the
// bar/window background so the tiling gaps read as a subtle matte (light
// theme only; pitch-black OLED palettes stay #000000).
// Lives at the layer-shell Background level, below all windows.
PanelWindow {
    id: desktopBg

    WlrLayershell.layer:          WlrLayer.Background
    WlrLayershell.anchors.top:    true
    WlrLayershell.anchors.bottom: true
    WlrLayershell.anchors.left:   true
    WlrLayershell.anchors.right:  true
    WlrLayershell.keyboardFocus:  WlrKeyboardFocus.None

    color: Theme.desktopBg
}
