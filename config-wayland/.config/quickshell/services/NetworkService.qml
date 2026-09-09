pragma Singleton
import QtQuick
import Quickshell.Io

// Polls network-vpn-status.sh every 5 seconds.
// Exposes: text, cssClass, tooltip
Item {
    id: root
    visible: false

    readonly property string text:     _text
    readonly property string cssClass: _cssClass
    readonly property string tooltip:  _tooltip

    property string _text:     "󰤢"
    property string _cssClass: "network-down"
    property string _tooltip:  ""

    Process {
        id: proc
        command: ["sh", "-c", "~/dotfiles/scripts/bar-modules/vpn/network-vpn-status.sh"]
        running: false
        stdout: SplitParser {
            onRead: (line) => {
                try {
                    const j = JSON.parse(line.trim())
                    if (j.text)    root._text     = j.text
                    if (j.class)   root._cssClass = j.class
                    if (j.tooltip) root._tooltip  = j.tooltip
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }

    Component.onCompleted: proc.running = true
}
