import QtQuick
import Quickshell.Io
import "../.."

// Battery status – icon + % – charging uses green, warning pulses red.
// Hover slides out the remaining time to the LEFT of the percentage:
//   discharging → time to empty ("3:30h" / "43m")
//   charging    → time to full
// the bar row is right-anchored, so the module grows leftward and the
// percentage itself never moves.
Row {
    id: root

    property int  _pct:      -1
    property bool _charging: false
    property bool _warning:  false   // < 20% and discharging
    property string _timeLeft: ""    // "3:30h" – time to empty / to full

    readonly property var icons: [
        "󰂃","󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂁","󰂂","󰁹"
    ]

    function iconForPct(p) {
        if (p < 0) return icons[0]
        const i = Math.min(Math.floor(p / (100 / (icons.length - 1))), icons.length - 1)
        return icons[i]
    }

    // upower gives "time to empty: 42.6 minutes" (or "… hours" for long
    // runtimes) – v is the value in the unit reported by upower
    function formatTime(v, unit) {
        const totalMin = Math.round(unit === "hours" ? v * 60 : v)
        const hh = Math.floor(totalMin / 60)
        const mm = totalMin % 60
        return hh > 0 ? (hh + ":" + String(mm).padStart(2, "0") + "h")
                      : (mm + "m")
    }

    // Hover reveals remaining time: to empty (discharging) or to full (charging)
    HoverHandler { id: batteryHover }

    height: Theme.barHeight
    spacing: 4

    // Slide-out detail – lives to the LEFT of the percentage
    Item {
        id: detailHolder
        height: parent.height
        width: (batteryHover.hovered && root._timeLeft.length > 0) ? detail.implicitWidth : 0
        clip: true
        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Text {
            id: detail
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            text: root._timeLeft
            opacity: detailHolder.width > 0
                ? detailHolder.width / Math.max(implicitWidth, 1) : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
            color: Qt.lighter(Theme.disabled, 1.25)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    // Main value – stays in place while the detail slides out
    Text {
        id: pctText
        text: _pct < 0 ? "󰂃 --%" : (iconForPct(_pct) + "\u200A" + _pct + "%")
        color: {
            if (_charging) return Theme.charging
            if (_warning)  return Theme.warning
            return Theme.foreground
        }
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        height: parent.height
        verticalAlignment: Text.AlignVCenter
    }

    // Battery warning pulse
    SequentialAnimation on opacity {
        running: root._warning
        loops: Animation.Infinite
        NumberAnimation { from: 1; to: 0.3; duration: 2000; easing.type: Easing.InOutSine }
        NumberAnimation { from: 0.3; to: 1; duration: 2000; easing.type: Easing.InOutSine }
        onStopped: root.opacity = 1
    }

    // Poll via upower
    Process {
        id: proc
        command: ["sh", "-c",
            "upower -i $(upower -e | grep -E 'BAT|battery' | head -1) 2>/dev/null | " +
            "awk '/percentage/{p=$2} /state/{s=$2} " +
            "/time to empty/{te=$4; ue=$5} /time to full/{tf=$4; uf=$5} " +
            "END{printf \"%s|%s|%s|%s|%s|%s\", p, s, te, ue, tf, uf}'"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.trim().split("|")
                if (parts.length >= 2) {
                    const pct = parseInt(parts[0])
                    const state = parts[1]
                    if (!isNaN(pct)) root._pct = pct
                    root._charging = (state === "charging")
                    root._warning  = (!root._charging && pct < 20)
                    if (state === "discharging") {
                        const v = parseFloat(parts[2])
                        const unit = parts[3] || ""
                        root._timeLeft = isNaN(v) ? "" : root.formatTime(v, unit)
                    } else if (state === "charging") {
                        const v = parseFloat(parts[4])
                        const unit = parts[5] || ""
                        root._timeLeft = isNaN(v) ? "" : root.formatTime(v, unit)
                    } else {
                        root._timeLeft = ""
                    }
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
