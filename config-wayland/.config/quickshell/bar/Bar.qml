import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "./modules"

// Main bar – full-width, height 22, anchored to top of a monitor.
// Instantiated once per screen by shell.qml via Variants; the instantiator
// passes the screen to anchor to.
PanelWindow {
    id: barWindow

    // Layer-shell: top of screen, fill width, exclusive zone so windows don't go under bar
    WlrLayershell.layer:        WlrLayer.Top
    WlrLayershell.anchors.top:  true
    WlrLayershell.anchors.left: true
    WlrLayershell.anchors.right: true
    WlrLayershell.exclusiveZone: Theme.barHeight
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    implicitHeight: Theme.barHeight
    color: Theme.background

    Item {
        anchors.fill: parent

        // ── Left ──────────────────────────────────────────────
        Row {
            id: leftSection
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            spacing: 0
            AppLauncher {}
            Workspaces {}
        }

        // ── Center – truly centered regardless of left/right widths ───────────
        Row {
            anchors.centerIn: parent
            spacing: 0
            Clock {}
            Weather {}
        }

        // ── Right ─────────────────────────────────────────────
        Row {
            id: rightSection
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: Theme.moduleSpacing
            Todo {}
            Hardware {}
            Audio {}
            Backlight {}
            Row {
                id: connectivityGroup
                spacing: 0   // BT + wifi read as one connectivity group
                Bluetooth {}
                Network {}
            }
            Battery {}
            PowerMenu {}
        }
    }
}
