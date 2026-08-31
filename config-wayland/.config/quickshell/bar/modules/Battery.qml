import QtQuick
import Quickshell.Io
import "../.."

// Battery status – icon + % – charging uses green, warning pulses red
Text {
    id: root

    property int  _pct:      -1
    property bool _charging: false
    property bool _warning:  false   // < 20% and discharging

    readonly property var icons: [
        "󰂃","󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂁","󰂂","󰁹"
    ]

    function iconForPct(p) {
        if (p < 0) return icons[0]
        const i = Math.min(Math.floor(p / (100 / (icons.length - 1))), icons.length - 1)
        return icons[i]
    }

    text: _pct < 0 ? "󰂃 --%"
                   : (iconForPct(_pct) + "\u2009" + _pct + "%")

    color: {
        if (_charging) return Theme.active
        if (_warning)  return Theme.warning
        return Theme.foreground
    }

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

    // Battery warning pulse
    SequentialAnimation on opacity {
        running: root._warning
        loops: Animation.Infinite
        NumberAnimation { from: 1; to: 0.3; duration: 2000; easing.type: Easing.InOutSine }
        NumberAnimation { from: 0.3; to: 1; duration: 2000; easing.type: Easing.InOutSine }
        onStopped: parent.opacity = 1
    }

    // Poll via upower
    Process {
        id: proc
        command: ["sh", "-c",
            "upower -i $(upower -e | grep -E 'BAT|battery' | head -1) 2>/dev/null | " +
            "awk '/percentage/{p=$2} /state/{s=$2} END{print p, s}'"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.trim().split(/\s+/)
                if (parts.length >= 2) {
                    const pct = parseInt(parts[0])
                    const state = parts[1]
                    if (!isNaN(pct)) root._pct = pct
                    root._charging = (state === "charging")
                    root._warning  = (!root._charging && pct < 20)
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }

    Component.onCompleted: proc.running = true
}
