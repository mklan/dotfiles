import QtQuick
import QtQuick.Controls
import Quickshell.Io
import "../.."
import "../overlays"
import "../../services"

// Network + VPN status
Item {
    id: root

    implicitHeight: Theme.barHeight
    implicitWidth: rowContent.implicitWidth

    HoverHandler { id: rowHover }

    // ── Floating tooltip (overlay window below the bar) ───────────────────
    property var _tip: null

    function ensureTip() {
        if (!_tip) _tip = tipComp.createObject(null)
        return _tip
    }

    Component {
        id: tipComp
        NetworkTooltip {}
    }

    // Reposition if the tooltip content changes while it's visible
    Connections {
        target: NetworkService
        function onTooltipChanged() {
            if (_tip && _tip.visible)
                _tip.place(wifiIcon.mapToItem(null, wifiIcon.width / 2, 0).x,
                           wifiIcon.Window.width)
        }
    }

    Row {
        id: rowContent
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        // ── Tailscale key – revealed on hover, shown LEFT of wifi icon ──────
        Text {
            id: vpnKey
            text: "\uF084"
            color: TailscaleService.active ? Theme.vpn : Theme.disabled
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 1   // +3 for better icon rendering
            height: Theme.barHeight
            leftPadding: Theme.padH
            rightPadding: 2
            topPadding: 1
            verticalAlignment: Text.AlignVCenter

            // Key stays visible while VPN is active, even without hover.
            // Slides in/out from the left when revealed by hover.
            opacity: (rowHover.hovered || TailscaleService.active) ? 1 : 0
            width:   (rowHover.hovered || TailscaleService.active) ? implicitWidth : 0
            clip: true
            visible: width > 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: tailscaleProc.running = true
            }

            Process {
                id: tailscaleProc
                command: ["/home/matze/dotfiles/scripts/bar-modules/vpn/tailscale-toggle.sh"]
                running: false
            }
        }

        // ── Wifi icon ────────────────────────────────────────────────────────
        Text {
            id: wifiIcon
            text: NetworkService.text
            height: Theme.barHeight
            color: _color
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 3   // +3 for better icon rendering
            leftPadding: Theme.padH
            rightPadding: Theme.padH
            verticalAlignment: Text.AlignVCenter

            property color _color: {
                switch (NetworkService.cssClass) {
                    case "wifi-home":    return Theme.vpn
                    case "wifi-up":      return Theme.foreground
                    case "network-down": return Theme.disabled
                    default:             return Theme.foreground
                }
            }

            // Left-click → nmtui
            Process {
                id: nmtuiProc
                command: ["kitty", "--class", "nmtui", "--hold", "sh", "-c", "nmtui"]
                running: false
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: nmtuiProc.running = true
            }

            // Tooltip: SSID, internal IP, home network reachability, VPN state
            HoverHandler {
                id: wifiHover
                onHoveredChanged: {
                    if (wifiHover.hovered && NetworkService.tooltip.length > 0) {
                        const t = ensureTip()
                        t.place(wifiIcon.mapToItem(null, wifiIcon.width / 2, 0).x,
                                wifiIcon.Window.width)
                        t.visible = true
                    } else if (_tip) {
                        _tip.visible = false
                    }
                }
            }
        }
    }
}
