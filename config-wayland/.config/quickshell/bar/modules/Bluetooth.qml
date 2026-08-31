import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../.."

// Bluetooth status + Galaxy Buds connect button
RowLayout {
    id: root
    spacing: 0

    property string _state: "off"   // "off" | "on" | "connected"
    property string _battText: ""

    Text {
        id: btIcon
        text: {
            switch (root._state) {
                case "connected": return ""
                case "on":        return ""
                default:          return ""
            }
        }
        color: {
            switch (root._state) {
                case "connected": return Theme.active
                case "on":        return Theme.foreground
                default:          return Theme.disabled
            }
        }
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        leftPadding: Theme.padH
        rightPadding: root._battText.length ? 2 : Theme.padH
        verticalAlignment: Text.AlignVCenter

        ToolTip.visible: btHover.hovered
        ToolTip.text: root._battText || "Bluetooth"
        ToolTip.delay: 300

        HoverHandler { id: btHover }

        Process {
            id: btManagerProc
            command: ["blueman-manager"]
            running: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: btManagerProc.running = true
        }
    }

    // Battery % when connected
    Text {
        visible: root._battText.length > 0
        text: root._battText
        color: Theme.active
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        rightPadding: Theme.padH
        verticalAlignment: Text.AlignVCenter
    }

    // Buds connect button
    Text {
        text: "󰥰"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        rightPadding: Theme.padH
        verticalAlignment: Text.AlignVCenter

        ToolTip.visible: budsHover.hovered
        ToolTip.text: "Connect Galaxy Buds"
        ToolTip.delay: 300

        HoverHandler { id: budsHover }

        Process {
            id: budsProc
            // Galaxy Buds+ MAC – mirrors waybar config
            command: ["sh", "-c", "bluetoothctl connect 58:18:62:0F:25:D6"]
            running: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: budsProc.running = true
        }
    }

    // Poll bluetoothctl
    Process {
        id: btProc
        command: ["sh", "-c",
            "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && " +
            "bluetoothctl info 2>/dev/null | grep -oP 'Battery Percentage: \\K\\d+' | head -1 || echo ''"]
        running: false
        stdout: SplitParser {
            property bool _powered: false
            property bool _hasBattery: false
            property string _bat: ""

            onRead: (line) => {
                const v = line.trim()
                if (!_powered) {
                    _powered = (v !== "")
                }
                if (/^\d+$/.test(v)) {
                    _hasBattery = true
                    _bat = v + "% "
                }
            }
            onStreamFinished: {
                if (_hasBattery) {
                    root._state = "connected"
                    root._battText = _bat
                } else if (_powered) {
                    root._state = "on"
                    root._battText = ""
                } else {
                    root._state = "off"
                    root._battText = ""
                }
                _powered = false
                _hasBattery = false
                _bat = ""
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: btProc.running = true
    }

    Component.onCompleted: btProc.running = true
}
