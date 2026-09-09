import QtQuick
import Quickshell.Io
import "../.."

// PulseAudio volume – polls pactl every 2s
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

    Process {
        id: proc
        // Get default sink volume and mute state
        command: ["sh", "-c",
            "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '[0-9]+(?=%)' | head -1; " +
            "pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -oP '(?<=Mute: )\\S+'"]
        running: false
        property int _lineIdx: 0
        stdout: SplitParser {
            onRead: (line) => {
                if (proc._lineIdx === 0) {
                    const v = parseInt(line.trim())
                    if (!isNaN(v)) root._vol = v.toString()
                } else {
                    root._muted = (line.trim() === "yes")
                }
                proc._lineIdx++
            }
        }
        onRunningChanged: {
            if (!running) proc._lineIdx = 0
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }

    Component.onCompleted: proc.running = true
}
