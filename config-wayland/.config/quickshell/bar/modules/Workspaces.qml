import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../.."
import "../overlays"

// Hyprland workspace switcher. Window icons via hyprctl clients.
// Each window icon is a separate element so it can show a title tooltip on hover.
Row {
    id: root
    spacing: 0

    // workspaceId -> [{class, title}]
    property var clientsByWs: ({})

    // Set of workspace IDs that are the active workspace on any monitor
    property var visibleWsIds: ({})

    // Color for a workspace: green if focused, teal if visible on another monitor
    function wsColor(wsId, isFocused) {
        if (isFocused) return Theme.active
        if (root.visibleWsIds[wsId]) return Theme.visibleWs
        return Theme.foreground
    }

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
        if (cl === "code" || cl.includes("vscode")) return iconMap["code"]
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
                            map[id].push({ cls: c.class || "", title: c.title || "", addr: c.address || "" })
                        }
                    }
                    root.clientsByWs = map
                } catch (_) {}
                _buf = ""
            }
        }
    }

    // Poll hyprctl monitors to know which workspaces are visible on any monitor
    Process {
        id: monitorsProc
        command: ["hyprctl", "monitors", "-j"]
        running: true
        property string _buf: ""
        stdout: SplitParser {
            onRead: (line) => { monitorsProc._buf += line }
        }
        onRunningChanged: {
            if (!running && _buf.length > 0) {
                try {
                    const arr = JSON.parse(_buf)
                    const map = {}
                    for (const m of arr) {
                        if (m.activeWorkspace && m.activeWorkspace.id > 0)
                            map[m.activeWorkspace.id] = true
                    }
                    root.visibleWsIds = map
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
                monitorsProc.running = true
            }
        }
        function onFocusedWorkspaceChanged() {
            clientsProc.running = true
            monitorsProc.running = true
        }
    }

    // ── Shared tooltip (one at a time, reused across all icons) ──────────
    property var _tip: null

    function ensureTip() {
        if (!_tip) _tip = tipComp.createObject(null)
        return _tip
    }

    Component {
        id: tipComp
        WindowTooltip {}
    }

    // ── Click-to-focus: focus a specific window by address ────────────────
    // Temporarily disables cursor warps so the mouse stays on the bar.
    Timer {
        id: cursorWarpsRestore
        interval: 150
        onTriggered: Hyprland.dispatch("hl.config({general={cursor_warps=true}})")
    }

    // Hide the tooltip only when the cursor leaves the entire workspace row.
    // This prevents flicker when moving between icons (gaps between them).
    HoverHandler {
        id: barHover
        onHoveredChanged: {
            if (!barHover.hovered && root._tip)
                root._tip.visible = false
        }
    }

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            id: wsDelegate
            required property var modelData

            visible: modelData.id > 0
            implicitWidth: visible ? rowLayout.implicitWidth + 10 : 0
            implicitHeight: Theme.barHeight

            Row {
                id: rowLayout
                anchors.centerIn: parent
                spacing: 0

                // Workspace number
                Text {
                    id: wsNum
                    text: "" + modelData.id
                    color: root.wsColor(modelData.id, modelData.focused)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    height: Theme.barHeight
                    verticalAlignment: Text.AlignVCenter
                    rightPadding: 2
                }

                // One icon per window, with individual hover → tooltip
                Repeater {
                    model: {
                        const _cby = root.clientsByWs   // reactive dependency
                        return _cby[modelData.id] || []
                    }

                    delegate: Text {
                        id: winIcon
                        required property var modelData
                        text: root.windowIcon(modelData.cls, modelData.title)
                        color: root.wsColor(wsDelegate.modelData.id, wsDelegate.modelData.focused)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        height: Theme.barHeight
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 4

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!modelData.addr) return
                                // Disable cursor warps so mouse stays on bar
                                Hyprland.dispatch("hl.config({general={cursor_warps=false}})")
                                // Focus the window (also switches to its workspace)
                                Hyprland.dispatch("hl.dsp.focus({ window = 'address:" + modelData.addr + "' })")
                                // Re-enable cursor warps after focus settles
                                cursorWarpsRestore.start()
                            }
                        }

                        HoverHandler {
                            id: iconHover
                            onHoveredChanged: {
                                if (iconHover.hovered) {
                                    const t = root.ensureTip()
                                    t.text = modelData.title || modelData.cls || "Unknown"
                                    t.place(winIcon.mapToItem(null, winIcon.width / 2, 0).x,
                                            winIcon.Window.width)
                                    t.visible = true
                                }
                            }
                        }
                    }
                }
            }

            // Click workspace background to switch
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                z: -1
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
            }
        }
    }
}
