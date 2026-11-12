import QtQuick
import Quickshell.Io
import "../.."

// CPU% + CPU°C + Memory — refreshed every 3s (was 30s, so the bar showed
// ~half-minute-old numbers).
// CPU% is computed from /proc/stat deltas: instant and cheap, unlike
// `top -bn1` which itself takes ~a second to sample.
Row {
    id: root

    property real cpuPct: -1   // % CPU usage
    property real tempC:  -1   // °C
    property real memPct: -1   // % of total memory used
    property string memGb: ""  // used memory in GB (for display)

    property real cpuWarn:  80
    property real tempWarn: 55   // orange from here
    property real tempCrit: 60   // red from here
    property real memWarn:  80

    // Previous /proc/stat sample for delta computation
    property double _prevTotal: -1
    property double _prevIdle: -1

    height: Theme.barHeight
    leftPadding: Theme.padH
    rightPadding: Theme.padH

    Text {
        id: cpuLabel
        height: parent.height
        text: root.cpuPct < 0 ? "C: --%" : "C: " + Math.round(root.cpuPct) + "%"
        color: root.cpuPct >= root.cpuWarn ? Theme.warning : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: tempLabel
        height: parent.height
        text: root.tempC < 0 ? "" : "/" + Math.round(root.tempC) + "\u00B0C"
        color: {
            if (root.tempC < root.tempWarn) return Theme.foreground
            return root.tempC >= root.tempCrit ? Theme.warning : Theme.warningOrange
        }
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: memLabel
        height: parent.height
        text: root.memGb ? "M: " + root.memGb + "GB" : "M: --GB"
        color: root.memPct >= root.memWarn ? Theme.warning : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        verticalAlignment: Text.AlignVCenter
        leftPadding: Theme.moduleSpacing
    }

    Process {
        id: cpuProc
        command: ["sh", "-c",
            "awk '/^cpu /{print ($2+$3+$4+$5+$6+$7+$8)\" \"($5+$6)}' /proc/stat"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.trim().split(/\s+/)
                if (parts.length < 2) return
                const total = parseFloat(parts[0])
                const idle = parseFloat(parts[1])
                if (isNaN(total) || isNaN(idle)) return
                if (root._prevTotal >= 0) {
                    const dt = total - root._prevTotal
                    const di = idle - root._prevIdle
                    if (dt > 0)
                        root.cpuPct = Math.max(0, Math.min(100, 100 * (1 - di / dt)))
                }
                root._prevTotal = total
                root._prevIdle = idle
            }
        }
    }

    Process {
        id: tempProc
        command: ["sh", "-c",
            "awk '{if($1>max)max=$1}END{if(max>0)printf \"%.0f\", max/1000}' /sys/class/thermal/thermal_zone*/temp"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const v = line.trim()
                if (v !== "") root.tempC = parseFloat(v)
            }
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c",
            "awk '/^MemTotal:/{t=$2}/^MemAvailable:/{a=$2}END{printf \"%.1f %.0f\", (t-a)/1048576, (t-a)*100/t}' /proc/meminfo"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.trim().split(/\s+/)
                if (parts.length >= 2) {
                    root.memGb  = parts[0]
                    root.memPct = parseFloat(parts[1])
                }
            }
        }
    }

    function refresh() {
        cpuProc.running  = true
        tempProc.running = true
        memProc.running  = true
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    // Second CPU sample shortly after startup so the first real % shows
    // without waiting a full interval (deltas need two samples)
    Timer {
        interval: 700
        running: true
        repeat: false
        onTriggered: cpuProc.running = true
    }

    Component.onCompleted: root.refresh()
}
