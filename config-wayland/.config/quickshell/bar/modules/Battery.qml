import QtQuick
import Quickshell.Services.UPower
import "../.."

// Battery status – event-driven via UPower D-Bus, so plug/unplug and
// percentage changes reflect instantly instead of waiting for the next
// upower poll. Icon + % – charging uses green, warning pulses red.
// Hover slides out the remaining time to the LEFT of the percentage:
//   discharging → time to empty ("3:30h" / "43m")
//   charging    → time to full
// the bar row is right-anchored, so the module grows leftward and the
// percentage itself never moves.
Row {
    id: root

    property var _dev: UPower.displayDevice
    property bool _ready: _dev !== null && _dev.ready

    property int _pct: _ready ? Math.round(_dev.percentage * 100) : -1
    property bool _charging: _ready && _dev.state === UPowerDeviceState.Charging
    property bool _warning: _ready && !_charging && _pct >= 0 && _pct < 20

    property string _timeLeft: {
        if (!_ready) return ""
        if (_dev.state === UPowerDeviceState.Discharging) return root.formatSecs(_dev.timeToEmpty)
        if (_dev.state === UPowerDeviceState.Charging) return root.formatSecs(_dev.timeToFull)
        return ""
    }

    readonly property var icons: [
        "󰂃","󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂁","󰂂","󰁹"
    ]

    function iconForPct(p) {
        if (p < 0) return icons[0]
        const i = Math.min(Math.floor(p / (100 / (icons.length - 1))), icons.length - 1)
        return icons[i]
    }

    // UPower reports seconds – format like the old upower output did
    function formatSecs(sec) {
        if (sec === undefined || sec === null || isNaN(sec) || sec <= 0) return ""
        const totalMin = Math.round(sec / 60)
        if (totalMin <= 0) return ""
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
            color: Theme.muted
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
}
