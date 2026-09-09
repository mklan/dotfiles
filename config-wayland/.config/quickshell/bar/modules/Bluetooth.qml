import QtQuick
import QtQuick.Controls
import Quickshell.Io
import "../.."

// Bluetooth status + Galaxy Buds connect button (drawer-style: buds shown on hover)
Item {
    id: root
    implicitHeight: Theme.barHeight
    implicitWidth: rowContent.implicitWidth

    property string _state:    "off"  // "off" | "on" | "connected"
    property string _battText: ""

    HoverHandler { id: rowHover }

    Row {
        id: rowContent
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        // ── Galaxy Buds connect – revealed on hover, shown LEFT of BT icon ───
        Text {
            id: budsBtn
            text: "\uDB82\uDD70"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 5   // Material Symbols glyph – bumped to match BT icon
            height: Theme.barHeight
            leftPadding: Theme.padH
            rightPadding: 2
            verticalAlignment: Text.AlignVCenter

            // Slides in/out from the left on hover (drawer style)
            opacity: rowHover.hovered ? 1 : 0
            width:   rowHover.hovered ? implicitWidth : 0
            clip: true
            visible: width > 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: budsProc.running = true
            }

            Process {
                id: budsProc
                command: ["sh", "-c", "bluetoothctl connect 58:18:62:0F:25:D6"]
                running: false
            }
        }

        // ── Main BT icon ──────────────────────────────────────────────────────
        Text {
            id: btIcon
            text: {
                switch (root._state) {
                    case "connected": return "\uF294"
                    case "on":        return "\uF294"
                    default:          return "\uF294"
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
            height: Theme.barHeight
            leftPadding:  Theme.padH
            rightPadding: root._battText.length ? 2 : Theme.padH
            verticalAlignment: Text.AlignVCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: btManagerProc.running = true
            }

            Process { id: btManagerProc; command: ["blueman-manager"]; running: false }
        }

        // ── Battery % when connected ──────────────────────────────────────────
        Text {
            visible: root._battText.length > 0
            text: root._battText
            color: Theme.active
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            height: Theme.barHeight
            rightPadding: Theme.padH
            verticalAlignment: Text.AlignVCenter
        }
    }

    // ── Poll bluetoothctl ─────────────────────────────────────────────────────
    Process {
        id: btProc
        command: ["sh", "-c",
            "if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then echo ON; " +
            "bluetoothctl info 2>/dev/null | grep -oP 'Battery Percentage: \\K\\S+' | head -1; " +
            "else echo OFF; fi"]
        running: false
        property bool _powered: false
        property bool _hasBattery: false
        property string _bat: ""

        stdout: SplitParser {
            onRead: (line) => {
                const v = line.trim()
                if (v === "ON" || v === "OFF") {
                    btProc._powered = (v === "ON")
                    return
                }
                // bluetoothctl reports battery as hex: "0x64 (100)" or decimal
                let pct = NaN
                if (v.startsWith("0x")) pct = parseInt(v.slice(2), 16)
                else if (/^\d+$/.test(v)) pct = parseInt(v)
                if (!isNaN(pct)) { btProc._hasBattery = true; btProc._bat = pct + "% " }
            }
        }
        onRunningChanged: {
            if (!running) {
                if (_hasBattery)    { root._state = "connected"; root._battText = _bat }
                else if (_powered)  { root._state = "on";        root._battText = "" }
                else                { root._state = "off";       root._battText = "" }
                _powered = false; _hasBattery = false; _bat = ""
            }
        }
    }

    Timer { interval: 2000; running: true; repeat: true; onTriggered: btProc.running = true }
    Component.onCompleted: btProc.running = true
}
