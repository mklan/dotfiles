pragma Singleton
import QtQuick
import Quickshell.Io

// Polls weather every 10 minutes.
// Exposes: text (e.g. "☀ 21°C"), tooltip, icon
QtObject {
    id: root

    readonly property string text:    _text
    readonly property string tooltip: _tooltip

    property string _text:    " 󰅐 ?"
    property string _tooltip: "Weather unavailable"

    Process {
        id: proc
        command: ["sh", "-c", "~/.config/waybar/modules/weather/weather.sh"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                try {
                    const j = JSON.parse(line.trim())
                    if (j.text)    root._text    = j.text
                    if (j.tooltip) root._tooltip = j.tooltip
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 600000   // 10 minutes
        running: true
        repeat: true
        onTriggered: proc.running = true
    }

    Component.onCompleted: proc.running = true
}
