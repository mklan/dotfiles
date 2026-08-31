import QtQuick
import Quickshell.Io
import "../.."
import "../../services"

// Network + VPN status – driven by NetworkService singleton
// Colors: wifi-vpn-up=#89beba, wifi-up=#ff9c9e (pulse), network-down=#868d80
Text {
    id: root

    text: NetworkService.text
    color: _color
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

    property color _color: {
        switch (NetworkService.cssClass) {
            case "wifi-vpn-up":  return Theme.vpn
            case "wifi-up":      return Theme.warning
            case "network-down": return Theme.disabled
            default:             return Theme.foreground
        }
    }

    ToolTip.visible: hover.hovered
    ToolTip.text: NetworkService.tooltip
    ToolTip.delay: 300

    HoverHandler { id: hover }

    // Left-click → nmtui
    Process {
        id: nmtuiProc
        command: ["kitty", "--class", "nmtui", "--hold", "sh", "-c", "nmtui"]
        running: false
    }

    // Right-click → tailscale toggle
    Process {
        id: tailscaleProc
        command: ["sh", "-c", "~/.config/waybar/modules/vpn/tailscale-toggle.sh"]
        running: false
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton)
                nmtuiProc.running = true
            else
                tailscaleProc.running = true
        }
    }

    // Pulse animation for wifi-up (no VPN)
    SequentialAnimation on opacity {
        running: NetworkService.cssClass === "wifi-up"
        loops: Animation.Infinite
        NumberAnimation { from: 0.3; to: 1;   duration: 450; easing.type: Easing.OutQuad }
        NumberAnimation { from: 1;   to: 0.4; duration: 450; easing.type: Easing.InQuad  }
        NumberAnimation { from: 0.4; to: 1;   duration: 600; easing.type: Easing.OutQuad }
        onStopped: parent.opacity = 1
    }
}
