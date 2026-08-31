import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../.."

// Hyprland workspace switcher.
// Shows each workspace as "id [window-icons]", highlights active one.
RowLayout {
    id: root
    spacing: 0

    property var windowRewrite: ({
        "firefox":   "",
        "private":   "󰗹",
        "chrome":    "",
        "code":      "",
        "kitty":     "",
        "thunar":    "",
        "vlc":       "󰕼",
        "mpv":       "",
        "default":   "󰘔"
    })

    function windowIcon(cls, title) {
        if (!cls) return windowRewrite["default"]
        const cl = cls.toLowerCase()
        if (cl.includes("firefox")) {
            if (title && title.toLowerCase().includes("private browsing"))
                return windowRewrite["private"]
            return windowRewrite["firefox"]
        }
        if (cl.includes("chrome"))  return windowRewrite["chrome"]
        if (cl === "code")          return windowRewrite["code"]
        if (cl === "kitty")         return windowRewrite["kitty"]
        if (cl === "thunar")        return windowRewrite["thunar"]
        if (cl.includes("vlc"))     return windowRewrite["vlc"]
        if (cl === "mpv")           return windowRewrite["mpv"]
        return windowRewrite["default"]
    }

    // Build icon string from workspace's clients list (if available)
    function buildLabel(ws) {
        let icons = ""
        // clients is ObjectModel<HyprlandWindow> in Quickshell.Hyprland
        if (ws.clients) {
            for (let i = 0; i < ws.clients.count; i++) {
                const win = ws.clients.get(i)
                icons += windowIcon(win.resourceClass || win.wClass || "", win.title || "")
            }
        }
        return ws.id + (icons.length ? " " + icons : "")
    }

    Repeater {
        // Sort by workspace id for consistent ordering
        model: Hyprland.workspaces

        delegate: Item {
            required property var modelData

            property bool isActive: Hyprland.focusedWorkspace !== null &&
                                    Hyprland.focusedWorkspace.id === modelData.id

            implicitWidth: wsText.implicitWidth + 18   // ≈0.9em each side
            implicitHeight: Theme.barHeight

            Text {
                id: wsText
                anchors.centerIn: parent
                text: root.buildLabel(modelData)
                color: isActive ? Theme.active : Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }
        }
    }
}
