import QtQuick
import Quickshell
import Quickshell.Wayland
import "../.."
import "../../services"

// Floating tooltip window – appears below the bar, centered under the wifi icon.
// Native Qt ToolTip can't escape the layer-shell panel (it gets clipped at the
// screen edge), so we use a small overlay-layer window instead.
PanelWindow {
    id: tip
    visible: false

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.anchors.top:   true
    WlrLayershell.anchors.right: true
    WlrLayershell.margins.top:   Theme.barHeight - 20  // flush under the bar, like dunst
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    color: "transparent"
    width:  box.implicitWidth
    height: box.implicitHeight

    // Center the tooltip under the icon (iconCenterX in window coords),
    // clamped so it never leaves the screen.
    function place(iconCenterX, screenWidth) {
        const w = box.implicitWidth
        const right = Math.min(Math.max(0, screenWidth - iconCenterX - w / 2),
                               screenWidth - w)
        WlrLayershell.margins.right = Math.round(right)
    }

    Rectangle {
        id: box
        implicitWidth:  label.implicitWidth + 18
        implicitHeight: label.implicitHeight + 10
        color: "#0d0d0d"
        border.color: Theme.disabled
        border.width: 1
        radius: 3

        Text {
            id: label
            anchors.centerIn: parent
            text: NetworkService.tooltip
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}
