import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../.."

// Hyprland workspace switcher. Window icons via hyprctl clients.
Row {
    id: root
    spacing: 0

    // workspaceId -> [{class, title}]
    property var clientsByWs: ({})

    property var iconMap: ({
        "firefox":  "\uF269",
        "private":  "\uDB81\uDDF9",   // 󰗹 nf-md-incognito
        "chrome":   "\uF268",
        "code":     "\uE70C",
        "kitty":    "\uF489",
        "thunar":   "\uEAF0",
        "vlc":      "\uDB81\uDD7C",
        "mpv":      "\uF36E",
        "default":  "\uDB81\uDE14"
    })

    function windowIcon(cls, title) {
        if (!cls) return iconMap["default"]
        const cl = cls.toLowerCase()
        if (cl.includes("firefox")) {
            // waybar: class<firefox> title<.*Mozilla Firefox Private Browsing*>
            if (title && /private browsing/i.test(title))
                return iconMap["private"]
            return iconMap["firefox"]
        }
        if (cl.includes("chrome"))  return iconMap["chrome"]
        if (cl === "code")          return iconMap["code"]
        if (cl === "kitty")         return iconMap["kitty"]
        if (cl === "thunar")        return iconMap["thunar"]
        if (cl.includes("vlc"))     return iconMap["vlc"]
        if (cl === "mpv")           return iconMap["mpv"]
        return iconMap["default"]
    }

    // Poll hyprctl clients to build workspace→window map
    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]
        running: true
        property string _buf: ""
        stdout: SplitParser {
            onRead: (line) => { clientsProc._buf += line }
        }
        onRunningChanged: {
            if (!running && _buf.length > 0) {
                try {
                    const arr = JSON.parse(_buf)
                    const map = {}
                    for (const c of arr) {
                        const id = c.workspace && c.workspace.id
                        if (id > 0) {
                            if (!map[id]) map[id] = []
                            map[id].push({ cls: c.class || "", title: c.title || "" })
                        }
                    }
                    root.clientsByWs = map
                } catch (_) {}
                _buf = ""
            }
        }
    }

    // Refresh on window open/close/move events
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            const n = event.name
            if (n === "openwindow" || n === "closewindow" || n === "movewindow"
                    || n === "movewindowv2" || n === "activewindow") {
                clientsProc.running = true
            }
        }
        function onFocusedWorkspaceChanged() { clientsProc.running = true }
    }

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            required property var modelData

            visible: modelData.id > 0
            implicitWidth:  visible ? (wsText.implicitWidth + 18) : 0
            implicitHeight: Theme.barHeight

            Text {
                id: wsText
                anchors.centerIn: parent
                text: {
                    const _cby = root.clientsByWs   // reactive dependency
                    const clients = _cby[modelData.id] || []
                    const icons = clients.map(c => root.windowIcon(c.cls, c.title)).join(" ")
                    return icons ? (modelData.id + " " + icons) : ("" + modelData.id)
                }
                color: modelData.focused ? Theme.active : Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
            }
        }
    }
}
