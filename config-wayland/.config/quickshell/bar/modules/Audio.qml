import QtQuick
import Quickshell.Io
import "../.."

// System volume – event-driven via `pactl subscribe`, so the media keys
// (pamixer in hyprland binds) reflect within milliseconds instead of
// waiting for the next poll. A slow poll remains as fallback.
Text {
    id: root

    property string _vol: "--"
    property bool   _muted: false

    text: _muted ? "󰝟" : (_vol + "% 󰕾")
    height: Theme.barHeight
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

    // Re-query the current volume/mute state
    Process {
        id: queryProc
        command: ["sh", "-c",
            "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '[0-9]+(?=%)' | head -1; " +
            "pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -oP '(?<=Mute: )\\S'"]
        running: false
        property int _lineIdx: 0
        stdout: SplitParser {
            onRead: (line) => {
                if (queryProc._lineIdx === 0) {
                    const v = parseInt(line.trim())
                    if (!isNaN(v)) root._vol = v.toString()
                } else {
                    root._muted = (line.trim() === "yes")
                }
                queryProc._lineIdx++
            }
        }
        onRunningChanged: {
            if (!running) {
                queryProc._lineIdx = 0
                // An event arrived while querying – re-query so it isn't lost
                if (root._dirty) {
                    root._dirty = false
                    queryProc.running = true
                }
            }
        }
    }

    property bool _dirty: false

    function refresh() {
        if (queryProc.running) root._dirty = true
        else queryProc.running = true
    }

    // Long-lived event feed – emits the instant a sink changes volume/mute
    // or the server changes default sink (media keys, pavucontrol, ...)
    Process {
        id: subProc
        command: ["pactl", "subscribe"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                const t = line.trim()
                // Volume/mute changes arrive as sink events, default-sink
                // switches as server events. Other events (clients,
                // streams) are irrelevant and far more frequent – ignore them
                // so we don't respawn the query constantly while media plays.
                if (t.indexOf(" on sink ") >= 0 || t.indexOf(" on server") >= 0)
                    root.refresh()
            }
        }
        onRunningChanged: {
            // Keep the feed alive – restart if it ever exits
            if (!running) subRestart.restart()
        }
    }

    Timer {
        id: subRestart
        interval: 1000
        running: false
        repeat: false
        onTriggered: subProc.running = true
    }

    // Fallback poll (missed events) + feed watchdog
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            if (!subProc.running) subProc.running = true
            else root.refresh()
        }
    }

    Component.onCompleted: {
        subProc.running = true
        queryProc.running = true
    }
}
