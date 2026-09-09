pragma Singleton
import QtQuick
import Quickshell.Io

// Polls weather every 10 minutes.
// Detects wake-from-sleep via a watchdog timer and refreshes immediately.
// Exposes: text (e.g. "☀ 21°C"), tooltip, icon
Item {
    id: root
    visible: false

    readonly property string text:    _text
    readonly property string tooltip: _tooltip

    property string _text:    " 󰅐 ?"
    property string _tooltip: "Weather unavailable"

    // ── Fetch process ──────────────────────────────────────────
    Process {
        id: proc
        command: ["sh", "-c", "~/dotfiles/scripts/bar-modules/weather/weather.sh"]
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

    // ── Normal poll every 10 min ───────────────────────────────
    Timer {
        id: pollTimer
        interval: 600000   // 10 minutes
        running: true
        repeat: true
        onTriggered: proc.running = true
    }

    // ── Sleep-detection watchdog ───────────────────────────────
    // Fires every 30 s.  If wall-clock time since last fire is
    // more than 3× the interval, the system was asleep → refresh now.
    Timer {
        id: watchdog
        interval: 30000    // 30 seconds
        running: true
        repeat: true

        property double lastFired: Date.now()

        onTriggered: {
            const now     = Date.now()
            const elapsed = now - lastFired
            lastFired     = now

            if (elapsed > interval * 3) {   // slept for >90 s
                proc.running = true
                pollTimer.restart()         // reset 10-min cadence
            }
        }
    }

    Component.onCompleted: proc.running = true
}
