import QtQuick
import Quickshell.Io
import "../.."

// Screen backlight brightness % – event-driven via sysfs inotify, so the
// brightness media keys (brightness.sh in hyprland binds) reflect instantly
// instead of waiting for the next poll. A slow brightnessctl poll remains
// as fallback (missed events, device hotplug).
Text {
    id: root

    // Corrected at startup by detectProc (same rule as brightness.sh)
    property string _device: "amdgpu_bl1"
    property int _max: 0
    property string _pct: "--"

    property int _pctInt: parseInt(_pct) || 0

    function _fromRaw(raw) {
        const v = parseInt(String(raw).trim())
        if (!isNaN(v) && root._max > 0) {
            root._pct = Math.round(v * 100 / root._max).toString()
        }
    }

    text: _pct + "% " + (_pct !== "--" ? (_pctInt > 50 ? "\uF185" : "\uF111") : "")

    color: Theme.foreground
    height: Theme.barHeight
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

    // Live brightness value – inotify fires the moment brightnessctl writes
    FileView {
        id: brightFile
        path: "/sys/class/backlight/" + root._device + "/brightness"
        watchChanges: true
        onFileChanged: reload()
        onTextChanged: root._fromRaw(text())
    }

    // Static max – re-read on device change, then recompute with fresh max
    FileView {
        id: maxFile
        path: "/sys/class/backlight/" + root._device + "/max_brightness"
        watchChanges: true
        onFileChanged: reload()
        onTextChanged: {
            const v = parseInt(text().trim())
            if (!isNaN(v) && v > 0) {
                root._max = v
                root._fromRaw(brightFile.text())
            }
        }
    }

    // Detect the backlight device (same rule as brightness.sh)
    Process {
        id: detectProc
        command: ["sh", "-c",
            "brightnessctl -l 2>/dev/null | awk -F\"'\" '$4 == \"backlight\" {print $2; exit}'"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const d = line.trim()
                if (d.length > 0) root._device = d
            }
        }
    }

    // Fallback poll (slow – keys are covered by inotify above)
    Process {
        id: fbProc
        command: ["sh", "-c",
            "brightnessctl -m 2>/dev/null | awk -F, '{print $4}' | tr -d '%'"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const v = parseInt(line.trim())
                if (!isNaN(v)) root._pct = v.toString()
            }
        }
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: fbProc.running = true
    }

    Component.onCompleted: {
        detectProc.running = true
        fbProc.running = true
    }
}
