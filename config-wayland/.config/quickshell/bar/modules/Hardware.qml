import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../.."

// CPU% + CPU°C + Memory — polled every 30s
RowLayout {
    id: root
    spacing: 0

    property string cpuText:  "C: --%"
    property string tempText: ""
    property string memText:  "M: --Gb"

    // CPU usage
    Process {
        id: cpuProc
        command: ["sh", "-c",
            "top -bn1 | awk '/^%Cpu/ {printf \"%.0f\", 100-$8}'"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const v = line.trim()
                if (v) root.cpuText = "C: " + v + "%"
            }
        }
    }

    // CPU temperature (hwmon)
    Process {
        id: tempProc
        command: ["sh", "-c",
            "cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1 | awk '{printf \"%.0f\", $1/1000}'"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const v = line.trim()
                if (v) root.tempText = "/" + v + "°C"
            }
        }
    }

    // Memory usage
    Process {
        id: memProc
        command: ["sh", "-c",
            "free -b | awk '/^Mem/ {printf \"%.1f\", $3/1073741824}'"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const v = line.trim()
                if (v) root.memText = "M: " + v + "Gb"
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

    Text {
        text: root.cpuText + root.tempText + "  " + root.memText
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        leftPadding: Theme.padH
        rightPadding: Theme.padH
        verticalAlignment: Text.AlignVCenter
    }
}
