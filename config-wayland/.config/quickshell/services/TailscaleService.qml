pragma Singleton
import QtQuick
import Quickshell.Io

// Polls tailscale state every 5s. Exposes: active
Item {
    id: root
    visible: false

    readonly property bool active: _active
    property bool _active: false

    Process {
        id: proc
        command: ["sh", "-c",
            "if ! systemctl is-active --quiet tailscaled 2>/dev/null; then echo off; " +
            "elif tailscale status >/dev/null 2>&1; then echo on; " +
            "else echo off; fi"]
        running: false
        stdout: SplitParser {
            onRead: (line) => { root._active = (line.trim() === "on") }
        }
    }

    Timer { interval: 5000; running: true; repeat: true; onTriggered: proc.running = true }
    Component.onCompleted: proc.running = true
}
