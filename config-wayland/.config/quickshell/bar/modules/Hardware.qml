import QtQuick
import Quickshell.Io
import "../.."

// CPU% + CPU°C + Memory — polled every 30s
// Color coding:
//   CPU    ≥ 80%   → red
//   temp   ≥ 55°C  → orange, ≥ 60°C → red
//   memory ≥ 80%   → red
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
            "top -bn1 | awk '/^%Cpu/ {printf \"%.0f\", 100-$8}'"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const v = line.trim()
                if (v !== "") root.cpuPct = parseFloat(v)
            }
        }
    }

    Process {
        id: tempProc
        command: ["sh", "-c",
            "cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1 | awk '{printf \"%.0f\", $1/1000}'"]
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
            "free -b | awk '/^Mem/ {printf \"%.1f %.0f\", $3/1073741824, $3*100/$2}'"]
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
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
