import QtQuick
import Quickshell.Io
import "../.."

// Screen backlight brightness %
Text {
    id: root

    property string _pct: "--"

    text: _pct + "% " + (_pct !== "--" ? (_pctInt > 50 ? "" : "") : "")

    property int _pctInt: parseInt(_pct) || 0

    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

    Process {
        id: proc
        command: ["sh", "-c",
            "brightnessctl -m 2>/dev/null | awk -F, '{print $4}' | tr -d '%' || " +
            "cat /sys/class/backlight/*/brightness 2>/dev/null | head -1"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const v = parseInt(line.trim())
                if (!isNaN(v)) root._pct = v.toString()
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }

    Component.onCompleted: proc.running = true
}
